import { Controller } from "@hotwired/stimulus"
import { createIcons, icons } from "lucide"

export default class extends Controller {
  connect() {
    addEventListener("turbo:frame-render", (event) => createIcons({ icons }))
    createIcons({ icons })
  }
}
