import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:installed_apps/app_category.dart';
import 'package:installed_apps/installed_apps.dart';

import '../../data/models/installed_game_model.dart';

/// Detects games installed on the user's device.
///
/// Supported platforms:
/// - **Android**: lists installed apps flagged as games via [InstalledApps].
/// - **Windows**: scans Steam libraries, Epic Games manifests and the
///   classic uninstall registry through PowerShell.
class InstalledGamesService {
  const InstalledGamesService();

  /// Fetches the list of games installed on the current device.
  Future<List<InstalledGameModel>> fetchInstalledGames() async {
    if (kIsWeb) {
      throw UnsupportedError('هذه الميزة غير مدعومة على الويب.');
    }

    if (Platform.isAndroid) {
      return _fetchAndroidGames();
    }

    if (Platform.isWindows) {
      return _fetchWindowsGames();
    }

    throw UnsupportedError('هذه الميزة مدعومة على أندرويد وويندوز فقط.');
  }

  // ─── Android ─────────────────────────────────────────────────────────

  Future<List<InstalledGameModel>> _fetchAndroidGames() async {
    final apps = await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      excludeNonLaunchableApps: true,
      withIcon: true,
    );

    // Extra safety net: some utility apps are misclassified as games.
    const nameNoise = [
      'launcher',
      'booster',
      'cleaner',
      'optimizer',
      'vpn',
      'wallpaper',
      'plugin',
      'theme',
      'store',
      'market',
      'keyboard',
      'storefront',
    ];

    final games = apps
        .where((app) => app.category == AppCategory.game)
        .where((app) {
          final name = app.name.toLowerCase();
          return !nameNoise.any((word) => name.contains(word));
        })
        .map(
          (app) => InstalledGameModel(
            name: app.name,
            packageName: app.packageName,
            icon: app.icon,
            source: 'android',
            sourceLabel: 'أندرويد',
          ),
        )
        .toList();

    games.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return games;
  }

  // ─── Windows ─────────────────────────────────────────────────────────

  Future<List<InstalledGameModel>> _fetchWindowsGames() async {
    final result = await Process.run('powershell.exe', const [
      '-NoProfile',
      '-NonInteractive',
      '-ExecutionPolicy',
      'Bypass',
      '-Command',
      _windowsScript,
    ], runInShell: false);

    if (result.exitCode != 0) {
      final error = (result.stderr as String).trim();
      throw Exception(
        'فشل فحص الجهاز: ${error.isEmpty ? result.exitCode : error}',
      );
    }

    final games = <InstalledGameModel>[];
    final seen = <String>{};

    for (final line in (result.stdout as String).split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      try {
        final json = jsonDecode(trimmed);
        if (json is! Map<String, dynamic>) continue;
        final name = (json['name'] as String? ?? '').trim();
        if (name.isEmpty) continue;

        final source = json['source'] as String? ?? 'windows';
        final id = (json['id'] as String? ?? '').trim();
        final uniqueKey = '$source:${id.isEmpty ? name : id}';
        if (!seen.add(uniqueKey.toLowerCase())) continue;

        games.add(
          InstalledGameModel(
            name: name,
            packageName: id.isEmpty ? name : id,
            source: source,
            sourceLabel: _sourceLabel(source),
          ),
        );
      } catch (_) {
        // Skip malformed lines.
      }
    }

    games.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return games;
  }

  static String _sourceLabel(String source) {
    switch (source) {
      case 'steam':
        return 'ستيم';
      case 'epic':
        return 'إيبك جيمز';
      default:
        return 'ويندوز';
    }
  }

  /// PowerShell script that:
  /// 1. Scans Steam library folders (`*.acf` files) for installed games.
  /// 2. Scans Epic Games manifests (`*.item` files) for installed games.
  /// 3. Scans the classic uninstall registry entries.
  /// Outputs one compact JSON object per line: {"name":..., "source":..., "id":...}
  static const String _windowsScript = r'''
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
$OutputEncoding = [System.Text.Encoding]::UTF8;
$results = New-Object System.Collections.ArrayList;
$seen = @{};
$seenNames = @{};

function Add-Game([string]$name, [string]$src, [string]$id) {
  $name = $name.Trim();
  if ([string]::IsNullOrWhiteSpace($name)) { return }
  $key = $src + ':' + $name.ToLowerInvariant();
  if ($seen.ContainsKey($key)) { return }
  $noiseGlobal = @('redistributable','common redist','directx','runtime','soundtrack','dedicated server','wallpaper','unreal engine','content builds','contentbuilds','launcher','xbox game bar','game bar','online services','server','sdk','tool','benchmark','workshop','driver','proton','steamvr','filmmaker','client');
  foreach ($k in $noiseGlobal) { if ($name.ToLowerInvariant().Contains($k)) { return } }
  $seen[$key] = $true;
  $seenNames[$name.ToLowerInvariant()] = $src;
  [void]$results.Add([PSCustomObject]@{ name = $name; source = $src; id = $id })
}

# ---- Steam ----
try {
  $steamPath = (Get-ItemProperty -Path 'HKCU:\Software\Valve\Steam' -Name SteamPath -ErrorAction Stop).SteamPath;
  $libs = @($steamPath);
  $vdfCandidates = @((Join-Path $steamPath 'steamapps\libraryfolders.vdf'), (Join-Path $steamPath 'config\libraryfolders.vdf'));
  foreach ($vdf in $vdfCandidates) {
    if (Test-Path $vdf) {
      $vdfContent = Get-Content $vdf -Raw -ErrorAction SilentlyContinue;
      foreach ($m in [regex]::Matches($vdfContent, '"path"\s+"([^"]+)"')) {
        $libs += ($m.Groups[1].Value -replace '\\\\','\');
      }
      break;
    }
  }
  foreach ($lib in $libs) {
    $acfDir = Join-Path $lib 'steamapps';
    if (Test-Path $acfDir) {
      Get-ChildItem $acfDir -Filter '*.acf' -ErrorAction SilentlyContinue | ForEach-Object {
        $acf = Get-Content $_.FullName -Raw -ErrorAction SilentlyContinue;
        $nm = [regex]::Match($acf, '"name"\s+"([^"]+)"');
        if ($nm.Success) {
          $appId = [regex]::Match($acf, '"appid"\s+"([^"]+)"');
          Add-Game $nm.Groups[1].Value 'steam' ('app_' + $appId.Groups[1].Value);
        }
      }
    }
  }
} catch {}

# ---- Epic Games ----
try {
  $epicDir = 'C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests';
  if (Test-Path $epicDir) {
    Get-ChildItem $epicDir -Filter '*.item' -ErrorAction SilentlyContinue | ForEach-Object {
      try {
        $itemJson = Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json;
        if ($itemJson.DisplayName) { Add-Game ([string]$itemJson.DisplayName) 'epic' ([string]$itemJson.AppName); }
      } catch {}
    }
  }
} catch {}

# ---- Classic uninstall registry (games only) ----
$regPaths = @(
  'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
  'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
);
$noise = @('update','redistributable','runtime','driver','sdk','framework','service pack','language pack','hotfix','bonjour','webview','visual c++','security','antivirus','component','toolkit','helper','plugin','extension','diagnostic','browser','office','.net','prerequisite','wizard','installer','setup','configuration','launcher','client','connect','game bar','xbox','gear','widget','booster','cleaner','vpn','firewall','printer','scanner','adobe','microsoft','google','java','python','node','git','docker','mysql','zip','rar','7-zip','reader','player','teamviewer','anydesk','zoom','discord','skype','slack','teams','whatsapp','telegram','signal','spotify','netflix','vlc','winrar','winzip','notepad','code editor','ide','studio','autocad','blender','photoshop','lightroom','illustrator','after effects','premiere','audacity','obs','streamlabs','screenshot','screen recorder','capture','clipper','translator','converter','downloader','optimizer','monitor','defender','antimalware','msi','razer','asus','gigabyte','logitech','corsair','hyperx','steelseries','keyboard','mouse','headset','audio','sound','verifier','wptx64','steam');
$gamePublishers = @('valve','blizzard','activision','riot games','electronic arts','ea sports','ubisoft','rockstar','take-two','2k games','bethesda','zenimax','id software','cd projekt','gog','square enix','sega','bandai namco','capcom','konami','koei','paradox','focus home','epic games','wargaming','gaijin','frontier developments','coffee stain','larian','mihoyo','hoyoverse','tencent','krafton','pubg','deep silver','thq','team17','devolver','gameloft','nexon','smilegate','infinity ward','sledgehammer','treyarch','naughty dog','insomniac','quantic dream','remedy','supergiant','gearbox','crytek','dice','maxis','respawn','popcap','king','scopely','zynga','supercell','mojang','343 industries','playground games','turn 10','the coalition','machinegames','arkane','tango gameworks','neowiz','grinding gear','hello games','colossal order','hinterland','unknown worlds','ghost ship','fatshark','tripwire');
$gameHints = @('edition','remastered','deluxe','legendary','definitive','game','gaming');
foreach ($p in $regPaths) {
  Get-ItemProperty $p -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | ForEach-Object {
    $dn = [string]$_.DisplayName;
    $lower = $dn.ToLowerInvariant();
    $pub = [string]$_.Publisher;
    $pubLower = $pub.ToLowerInvariant();
    $isNoise = $false;
    foreach ($k in $noise) { if ($lower.Contains($k)) { $isNoise = $true; break } }
    if ($isNoise) { return }
    $isGamePublisher = $false;
    foreach ($k in $gamePublishers) { if ($pubLower.Contains($k)) { $isGamePublisher = $true; break } }
    $hasGameHint = $false;
    foreach ($k in $gameHints) { if ($lower -match ('\b' + [regex]::Escape($k) + '\b')) { $hasGameHint = $true; break } }
    if ($isGamePublisher -or $hasGameHint) {
      if ($seenNames.ContainsKey($dn.ToLowerInvariant())) { return }
      Add-Game $dn 'windows' $dn
    }
  }
}

foreach ($r in $results) { [Console]::Out.WriteLine(($r | ConvertTo-Json -Compress)) }
''';
}
