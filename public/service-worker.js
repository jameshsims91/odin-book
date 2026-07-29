// public/service-worker.js

// Listen for the push event from Apple/Google push servers
self.addEventListener('push', function(event) {
  // Parse the encrypted payload payload sent from your Rails background job
  const data = event.data ? event.data.json() : { title: 'Alert', body: 'New notification!' };

  const options = {
    body: data.body,
    icon: '/icon.png',  // Optional: Place a 192x192 icon.png in your public/ folder later
    badge: '/badge.png', // Optional: Place a monochrome badge image for mobile status bars
    data: { url: data.url } // Pass the redirect URL down to the notification click event
  };

  // Keep the service worker alive until the notification is displayed on the device screen
  event.waitUntil(
    self.registration.showNotification(data.title, options)
  );
});

// Listen for when a user clicks on the notification banner
self.addEventListener('notificationclick', function(event) {
  event.notification.close(); // Dismiss the notification banner instantly

  // Extract the target URL we attached in the options block above
  const targetUrl = event.notification.data.url || '/';

  // Open your application view or focus the existing tab if it's already open
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function(clientList) {
      for (const client of clientList) {
        if (client.url === targetUrl && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow(targetUrl);
      }
    })
  );
});