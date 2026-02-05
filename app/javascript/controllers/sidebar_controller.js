import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sidebar",
    "openMenu",
    "closeMenu"
  ]

  connect() {
    console.log('connected!')
    console.log(this)

    this.openMenuTarget.addEventListener("click", () => {
      this.sidebarTarget.classList.remove("-translate-x-full")
    })

    this.closeMenuTarget.addEventListener("click", () => {
      this.sidebarTarget.classList.add("-translate-x-full")
    })
  }
}
