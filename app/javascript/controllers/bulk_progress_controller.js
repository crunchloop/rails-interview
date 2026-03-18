import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    finished: Boolean,
    markDone: Boolean,
  }

  connect() {
    if (this.finishedValue && this.markDoneValue) {
      this.runConfetti()
    }
  }

  runConfetti() {
    // Lightweight, dependency-free confetti burst.
    // Runs once per element instance.
    if (this.element.dataset.confettiRan === "1") return
    this.element.dataset.confettiRan = "1"

    const colors = ["#ff6ea8", "#ff9b4a", "#4b92ff", "#fff6b7"]
    const count = 36
    const host = document.createElement("div")
    host.className = "confetti"
    this.element.appendChild(host)

    for (let i = 0; i < count; i++) {
      const piece = document.createElement("span")
      piece.className = "confetti__piece"
      piece.style.background = colors[i % colors.length]
      piece.style.left = `${Math.random() * 100}%`
      piece.style.transform = `translateY(0) rotate(${Math.random() * 180}deg)`
      piece.style.animationDelay = `${Math.random() * 120}ms`
      piece.style.animationDuration = `${700 + Math.random() * 500}ms`
      host.appendChild(piece)
    }

    setTimeout(() => host.remove(), 1600)
  }
}

