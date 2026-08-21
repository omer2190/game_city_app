import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// ⚠️ المنفذ الثابت المستخدم لخادم OAuth المحلي.
/// يجب أن يطابق تماماً الـ redirect URI المسجل في Google Cloud Console:
/// Google Cloud Console → Credentials → الـ Web client → Authorized redirect URIs
/// أضف: http://localhost:8080
const int _redirectPort = 8080;

/// Desktop (Windows / Linux / macOS) Google Sign-In via browser OAuth flow.
///
/// 1. Starts a temporary local HTTP server on a fixed port (8080).
/// 2. Opens the Google consent screen in the system browser.
/// 3. Waits for Google to redirect back with an authorization code.
/// 4. Exchanges the code for a Google ID token.
/// 5. Returns the ID token (to be sent to your backend).
Future<String?> signInWithGoogleDesktop({
  required String clientId,
  String? clientSecret,
  required String scopes,
}) async {
  const tag = '🔍 DESKTOP_OAUTH';
  debugPrint('$tag ═══════════ بدء OAuth على سطح المكتب ═══════════');
  debugPrint('$tag ▶ clientId: $clientId');
  debugPrint(
    '$tag ▶ clientSecret: ${clientSecret == null ? "غير مضبوط (null)" : "مضبوط ✅"}',
  );
  debugPrint('$tag ▶ scopes: $scopes');

  final state = _randomString(32);
  debugPrint('$tag ▶ state (لحماية CSRF): $state');

  // ⚠️ منفذ ثابت — يجب أن يطابق الـ redirect URI المسجل في Google Cloud Console
  final port = _redirectPort;
  debugPrint('$tag ▶ المنفذ المحلي الثابت: $port');

  final redirectUri = 'http://localhost:$port';
  debugPrint('$tag ▶ redirectUri: $redirectUri');

  // ── Build the Google OAuth consent URL ──
  final authUrl = Uri.https('accounts.google.com', '/o/oauth2/v2/auth', {
    'client_id': clientId,
    'redirect_uri': redirectUri,
    'response_type': 'code',
    'scope': scopes,
    'state': state,
    'access_type': 'offline',
    'prompt': 'consent',
  });
  debugPrint(
    '$tag ▶ رابط الموافقة (بدون state): ${authUrl.replace(queryParameters: {...authUrl.queryParameters, 'state': '***'})}',
  );

  // ── Open the system browser ──
  debugPrint('$tag ── [1/4] فتح المتصفح على شاشة موافقة جوجل ──');
  await _openBrowser(authUrl.toString());
  debugPrint('$tag     ✅ تم فتح المتصفح — بانتظار موافقة المستخدم...');

  // ── Listen for the OAuth callback ──
  final completer = Completer<String?>();
  HttpServer? server;

  try {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    debugPrint('$tag     ✅ الخادم المحلي يعمل على المنفذ $port');

    await for (final request in server) {
      debugPrint('$tag     📩 طلب وارد: ${request.method} ${request.uri}');
      final code = request.uri.queryParameters['code'];
      final returnedState = request.uri.queryParameters['state'];
      final error = request.uri.queryParameters['error'];

      if (error != null) {
        debugPrint('$tag     ⚠️ جوجل أعادت خطأ: $error');
        await _sendHtmlResponse(request);
        completer.complete(null);
        break;
      }

      if (code != null && returnedState == state) {
        debugPrint('$tag     ✅ تم استلام كود التفويض بنجاح');
        debugPrint(
          '$tag     code (أول 20 حرف): ${code.substring(0, code.length > 20 ? 20 : code.length)}...',
        );
        debugPrint('$tag     state مطابق ✅');
        await _sendHtmlResponse(request);
        completer.complete(code);
        break;
      }

      debugPrint(
        '$tag     ⚠️ طلب غير صالح (code=${code != null}, state مطابق=${returnedState == state})',
      );
      // Invalid request
      request.response
        ..statusCode = 400
        ..close();
    }
  } finally {
    await server?.close();
    debugPrint('$tag     ✅ تم إغلاق الخادم المحلي');
  }

  final code = await completer.future;
  if (code == null) {
    debugPrint('$tag ── ❌ أُلغي من قبل المستخدم (لا يوجد كود) ──');
    return null;
  }

  // ── Exchange authorization code for tokens ──
  debugPrint('$tag ── [2/4] استبدال كود التفويض بـ id_token ──');
  debugPrint('$tag     إرسال POST إلى oauth2.googleapis.com/token');
  debugPrint(
    '$tag     client_secret: ${clientSecret == null ? "غير مُرسل ❌" : "مُرسل ✅"}',
  );
  final tokenResponse = await http.post(
    Uri.https('oauth2.googleapis.com', '/token'),
    body: {
      'code': code,
      'client_id': clientId,
      if (clientSecret != null) 'client_secret': clientSecret,
      'redirect_uri': redirectUri,
      'grant_type': 'authorization_code',
    },
  );
  debugPrint('$tag     ✅ استجابة جوجل: HTTP ${tokenResponse.statusCode}');

  if (tokenResponse.statusCode != 200) {
    final body = tokenResponse.body;
    debugPrint('$tag     ❌ فشل التبادل — نص الاستجابة: $body');
    if (body.contains('client_secret is missing')) {
      throw Exception(
        '❌ هذا الـ Client ID من نوع Web application وليس Desktop app.\n'
        'اذهب إلى Google Cloud Console → Credentials وأنشئ عميلاً جديداً '
        'من نوع "Desktop app" ثم ضع الـ ID الجديد في _windowsGoogleClientId.',
      );
    }
    throw Exception(
      'فشل استبدال رمز التوثيق (${tokenResponse.statusCode}): $body',
    );
  }

  final tokenData = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
  debugPrint('$tag     ✅ مفاتيح استجابة التوكن: ${tokenData.keys.toList()}');
  final idToken = tokenData['id_token'] as String?;

  if (idToken == null || idToken.isEmpty) {
    debugPrint('$tag     ❌ لا يوجد id_token في الاستجابة');
    throw Exception('لم يتم العثور على id_token في استجابة الخادم.');
  }

  debugPrint(
    '$tag ── [3/4] تم الحصول على id_token ✅ (${idToken.length} حرف) ──',
  );
  debugPrint('$tag ── [4/4] إرجاع id_token إلى AuthController ──');
  debugPrint('$tag ═══════════ ✅ اكتمل OAuth على سطح المكتب ═══════════');
  return idToken;
}

// ──────────────────────────────────────────────
// Helpers
// ──────────────────────────────────────────────

Future<void> _openBrowser(String url) async {
  final uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw Exception('لا يمكن فتح المتصفح: $url');
  }
}

Future<void> _sendHtmlResponse(HttpRequest request) async {
  request.response
    ..headers.contentType = ContentType.html
    ..write(_buildSuccessPage());
  await request.response.close();
}

/// صفحة نجاح احترافية متوافقة مع الهوية البصرية للتطبيق
/// (خلفية بنفسجية داكنة + لمسات ذهبية + شعار + علامة صح متحركة)
String _buildSuccessPage() {
  return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Gaming City — تم تسجيل الدخول</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }

  body {
    font-family: 'Segoe UI', Tahoma, Arial, sans-serif;
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    background: radial-gradient(ellipse at 50% -20%, #3b1d63 0%, #23113E 45%, #140926 100%);
    overflow: hidden;
    position: relative;
  }

  /* ── جزيئات متوهجة في الخلفية ── */
  .particle {
    position: absolute;
    border-radius: 50%;
    background: rgba(238, 210, 91, 0.25);
    filter: blur(1px);
    animation: float 6s ease-in-out infinite;
  }
  .p1 { width: 8px; height: 8px; top: 15%; left: 12%; animation-delay: 0s; }
  .p2 { width: 5px; height: 5px; top: 70%; left: 20%; animation-delay: 1.2s; }
  .p3 { width: 10px; height: 10px; top: 25%; left: 80%; animation-delay: 2.1s; }
  .p4 { width: 6px; height: 6px; top: 80%; left: 75%; animation-delay: 0.6s; }
  .p5 { width: 4px; height: 4px; top: 45%; left: 90%; animation-delay: 1.8s; }
  .p6 { width: 7px; height: 7px; top: 60%; left: 8%; animation-delay: 2.6s; }

  @keyframes float {
    0%, 100% { transform: translateY(0) scale(1); opacity: 0.6; }
    50% { transform: translateY(-25px) scale(1.3); opacity: 1; }
  }

  .card {
    text-align: center;
    padding: 48px 56px;
    max-width: 420px;
    width: 90%;
    background: rgba(255, 255, 255, 0.04);
    border: 1px solid rgba(238, 210, 91, 0.18);
    border-radius: 24px;
    backdrop-filter: blur(12px);
    box-shadow: 0 20px 60px rgba(0, 0, 0, 0.45);
    animation: cardIn 0.7s cubic-bezier(0.22, 1, 0.36, 1) both;
    position: relative;
    z-index: 2;
  }

  @keyframes cardIn {
    from { opacity: 0; transform: translateY(30px) scale(0.95); }
    to { opacity: 1; transform: translateY(0) scale(1); }
  }

  /* ── الشعار ── */
  .logo {
    width: 72px;
    height: 72px;
    margin: 0 auto 20px;
    display: flex;
    align-items: center;
    justify-content: center;
    animation: logoPop 0.8s cubic-bezier(0.34, 1.56, 0.64, 1) 0.2s both;
  }
  @keyframes logoPop {
    from { opacity: 0; transform: scale(0.4) rotate(-12deg); }
    to { opacity: 1; transform: scale(1) rotate(0); }
  }

  /* ── دائرة علامة الصح ── */
  .check-circle {
    width: 96px;
    height: 96px;
    margin: 0 auto 24px;
    border-radius: 50%;
    background: radial-gradient(circle at 30% 30%, #f7e08a, #eed25b 60%, #c9a92e);
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 0 0 8px rgba(238, 210, 91, 0.12),
                0 0 40px rgba(238, 210, 91, 0.45),
                inset 0 -4px 10px rgba(0, 0, 0, 0.15);
    animation: pulse 2.2s ease-in-out infinite;
  }
  @keyframes pulse {
    0%, 100% { box-shadow: 0 0 0 8px rgba(238, 210, 91, 0.12), 0 0 40px rgba(238, 210, 91, 0.45), inset 0 -4px 10px rgba(0,0,0,0.15); }
    50% { box-shadow: 0 0 0 14px rgba(238, 210, 91, 0.06), 0 0 60px rgba(238, 210, 91, 0.6), inset 0 -4px 10px rgba(0,0,0,0.15); }
  }

  .check-svg { width: 52px; height: 52px; }
  .check-path {
    fill: none;
    stroke: #23113E;
    stroke-width: 7;
    stroke-linecap: round;
    stroke-linejoin: round;
    stroke-dasharray: 60;
    stroke-dashoffset: 60;
    animation: draw 0.6s ease-out 0.5s forwards;
  }
  @keyframes draw { to { stroke-dashoffset: 0; } }

  h1 {
    color: #eed25b;
    font-size: 26px;
    font-weight: 800;
    letter-spacing: 0.5px;
    margin-bottom: 8px;
    animation: fadeUp 0.6s ease 0.6s both;
  }

  .message {
    color: rgba(255, 255, 255, 0.85);
    font-size: 15px;
    line-height: 1.7;
    margin-bottom: 28px;
    animation: fadeUp 0.6s ease 0.75s both;
  }

  @keyframes fadeUp {
    from { opacity: 0; transform: translateY(12px); }
    to { opacity: 1; transform: translateY(0); }
  }

  .btn {
    display: inline-block;
    padding: 12px 36px;
    border: none;
    border-radius: 50px;
    background: linear-gradient(135deg, #eed25b, #c9a92e);
    color: #23113E;
    font-size: 15px;
    font-weight: 700;
    cursor: pointer;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
    box-shadow: 0 6px 20px rgba(238, 210, 91, 0.35);
    animation: fadeUp 0.6s ease 0.9s both;
  }
  .btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 28px rgba(238, 210, 91, 0.5);
  }

  .countdown {
    margin-top: 20px;
    color: rgba(255, 255, 255, 0.45);
    font-size: 12.5px;
    animation: fadeUp 0.6s ease 1.05s both;
  }
  .countdown b { color: #eed25b; }
</style>
</head>
<body>
  <div class="particle p1"></div>
  <div class="particle p2"></div>
  <div class="particle p3"></div>
  <div class="particle p4"></div>
  <div class="particle p5"></div>
  <div class="particle p6"></div>

  <div class="card">
    <div class="logo">
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 480.19 624.2" width="72" height="72">
        <path fill="#eed25b" d="M477.34,490.82A291.78,291.78,0,0,0,460,430a325.53,325.53,0,0,0-16.26-34.64,76.38,76.38,0,0,0,6.6-52.52,86.62,86.62,0,0,0-6.18-17.79,60.36,60.36,0,0,0,2.57-7.19,64,64,0,0,0,.84-31.75c-3.49-15.4-12.36-29.84-26.47-43.16a56.17,56.17,0,0,0,1.36-30.27c-4.74-21-20.69-39.84-47.38-56.13-54.11-33-89.61-54.67-98-114.79v0a11.51,11.51,0,0,0-.4-3,224,224,0,0,1-1.54-26.85A11.72,11.72,0,0,0,265.39.13a11.47,11.47,0,0,0-13.21,11.34,243.91,243.91,0,0,0,1.94,31.87q0,4.45,0,8.7c0,.29,0,.59,0,.89,0,3.85.07,7.62.19,11.3.46,25.17,1.77,45,4.06,62.35,3.34,25.32,8.81,45.48,17.21,63.44C284.12,208.27,296,224.55,312,239.8c14.85,14.17,33.69,28,59.3,43.67,32.15,19.61,51.17,41.12,56.55,63.93a55.62,55.62,0,0,1,1.45,15.7A213.63,213.63,0,0,0,393,330.94a175.93,175.93,0,0,0-50.48-24.29c-33.56-10.06-67-10.06-102.45-10.06s-68.88,0-102.44,10.06a175.93,175.93,0,0,0-50.48,24.29,213.58,213.58,0,0,0-35.85,31.67A56,56,0,0,1,52.8,347.4c5.38-22.81,24.4-44.32,56.54-63.93C135,267.84,153.8,254,168.65,239.8c16-15.25,27.9-31.53,36.44-49.78,8.4-18,13.87-38.12,17.21-63.44,2.29-17.4,3.6-37.18,4.06-62.35.12-3.68.19-7.45.19-11.3,0-.3,0-.6,0-.89q0-4.24,0-8.7a245.31,245.31,0,0,0,1.94-31.49A11.72,11.72,0,0,0,218.68.12a11.47,11.47,0,0,0-13.13,11.35A223.8,223.8,0,0,1,204,38.7a11.51,11.51,0,0,0-.4,3v0c-8.43,60.12-43.93,81.78-98,114.79-26.7,16.29-42.64,35.18-47.38,56.13A56.17,56.17,0,0,0,59.55,243c-14.11,13.32-23,27.76-26.47,43.16a64,64,0,0,0,.84,31.75,58.64,58.64,0,0,0,2.57,7.19,86.62,86.62,0,0,0-6.18,17.79,76.49,76.49,0,0,0,6.36,52.07A326.46,326.46,0,0,0,20.17,430,291.78,291.78,0,0,0,2.85,490.82c-3.59,21.91-3.79,41.95-.6,59.57,3.68,20.32,11.82,37.1,24.2,49.89,15.44,16,30.05,23.78,44.67,23.91,10.58.11,20.69-3.63,31.83-11.74,8.87-6.46,17.53-15.09,26.7-24.22,26.64-26.56,56.84-56.65,110.44-56.65s83.8,30.09,110.44,56.65c9.17,9.13,17.83,17.76,26.7,24.22,11.14,8.11,21.25,11.85,31.83,11.74,14.62-.13,29.23-7.95,44.67-23.91,12.38-12.79,20.52-29.57,24.2-49.89C481.13,532.77,480.93,512.73,477.34,490.82Z"/>
      </svg>
    </div>

    <div class="check-circle">
      <svg class="check-svg" viewBox="0 0 52 52">
        <path class="check-path" d="M14 27 L22 35 L38 18"/>
      </svg>
    </div>

    <h1>Gaming City</h1>
    <p class="message">تم تسجيل الدخول بنجاح!<br>يمكنك الآن العودة إلى التطبيق.</p>


  </div>

<script>
  // إغلاق تلقائي بعد 5 ثوانٍ مع عدّاد تنازلي
  var seconds = 5;
  var el = document.getElementById('sec');
  var timer = setInterval(function () {
    seconds--;
    if (el) el.textContent = seconds;
    if (seconds <= 0) {
      clearInterval(timer);
      window.close();
    }
  }, 1000);
</script>
</body>
</html>
''';
}

String _randomString(int length) {
  final random = Random.secure();
  final values = List<int>.generate(length, (_) => random.nextInt(256));
  return base64UrlEncode(values).substring(0, length);
}
