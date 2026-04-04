importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBSRXQuCsqZOroa1Yr9kEf2k4KXDazY0Jw",
  appId: "1:1033131122028:web:d32ac1a6fa4ff2f20f2749",
  messagingSenderId: "1033131122028",
  projectId: "gaming-city-94354",
  authDomain: "gaming-city-94354.firebaseapp.com",
  storageBucket: "gaming-city-94354.firebasestorage.app"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log("[firebase-messaging-sw.js] Received background message ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png"
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});
