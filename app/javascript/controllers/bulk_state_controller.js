import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "feedback"]
  static values = { url: String }

  async submit() {
    const state = this.selectTarget.value
    const csrfToken = document.querySelector('meta[name="csrf-token"]').content

    this.feedbackTarget.textContent = "Updating…"

    try {
      const response = await fetch(this.urlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": csrfToken
        },
        body: JSON.stringify({ state })
      })

      const data = await response.json()
      this.feedbackTarget.textContent = response.ok ? data.message : data.error
    } catch {
      this.feedbackTarget.textContent = "Request failed"
    }
  }
}
