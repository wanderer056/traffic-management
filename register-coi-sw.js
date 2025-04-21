// register-coi-sw.js

if ('serviceWorker' in navigator) {
  const basePath = window.location.pathname.replace(/\/[^\/]*$/, '/') + 'coi-serviceworker.js';

  navigator.serviceWorker.register(basePath).then((registration) => {
    console.log('COOP/COEP Service Worker registered');

    if (registration.installing) {
      registration.installing.addEventListener('statechange', function (e) {
        if (e.target.state === 'activated') {
          window.location.reload();
        }
      });
    }
  }).catch((error) => {
    console.error('Service Worker registration failed:', error);
  });
}
