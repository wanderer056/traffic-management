// register-coi-sw.js

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/coi-serviceworker.js').then((registration) => {
    console.log('COOP/COEP Service Worker registered');

    // Force reload once the SW takes control
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

