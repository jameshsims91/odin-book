import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="web-push"
export default class extends Controller {
  static values = { publicKey: String }

  connect() {
    if ('serviceWorker' in navigator && 'PushManager' in window) {
      this.element.classList.remove("hidden")
    }
  }

  async subscribe(event) {
    event.preventDefault()

    try {
      const registration = await navigator.serviceWorker.register('/service-worker.js')
      const permission = await Notification.requestPermission()
      if (permission != 'granted') {
        alert("Notifications were denied. Please enable them in your browser settings to receive alerts.")
        return
      }

      const convertedPublicKey = this.urlBase64ToUint8Array(this.publicKeyValue)
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: convertedPublicKey
      })

      const response = await fetch('/web_push_subscriptions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify(subscription.toJSON())
      })

      if (response.ok) {
        alert("Successfully subscribed to notifications!")
      } else {
        console.error("Rails API failed to save the subscription.")
      }
    } catch (error) {
      console.error("Web Push Subscription failed:", error)
    }
  }

  urlBase64ToUint8Array(base64String) {
    const padding = '='.repeat((4 - base64String.length % 4) % 4)
    const base64 = (base64String + padding).replace(/\-/g, '+').replace(/_/g, '/')
    const rawData = window.atob(base64)
    const outputArray = new Uint8Array(rawData.length)
    for (let i = 0; i < rawData.length; ++i) {
      outputArray[i] = rawData.charCodeAt(i)
    }
    return outputArray
  }
}
