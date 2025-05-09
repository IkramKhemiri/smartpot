// web/firebase-messaging-sw.js
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.22.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: "AIzaSyArvzOtubZuI4dN_roYFrC2lAGfcgBttYw",
  authDomain: "smartpot-3d8a5.firebaseapp.com",
  projectId: "smartpot-3d8a5",
  storageBucket: "smartpot-3d8a5.firebasestorage.app",
  messagingSenderId: "24633911044",
  appId: "1:24633911044:web:61d31dfaf8d1a201019251",
  measurementId: "G-SSC9YD7K8F"
});

const messaging = firebase.messaging();
