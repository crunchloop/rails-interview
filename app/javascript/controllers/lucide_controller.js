import { Controller } from "@hotwired/stimulus"
import { createIcons, icons } from "lucide"

export default class extends Controller {
  connect() {
    createIcons({ icons })
  }
}
