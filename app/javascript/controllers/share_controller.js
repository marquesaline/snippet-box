// app/javascript/controllers/share_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rendered", "raw", "renderedButton", "rawButton", "copyButton"]
  static values = { source: String }

  showRendered() {
    this.renderedTarget.classList.remove("hidden")
    this.rawTarget.classList.add("hidden")
    this.renderedButtonTarget.classList.add("active")
    this.rawButtonTarget.classList.remove("active")
  }

  showRaw() {
    this.renderedTarget.classList.add("hidden")
    this.rawTarget.classList.remove("hidden")
    this.renderedButtonTarget.classList.remove("active")
    this.rawButtonTarget.classList.add("active")
  }

  copy() {
    let textToCopy
    
    if (!this.rawTarget.classList.contains("hidden")) {
      textToCopy = this.rawTarget.textContent
    } else {
      textToCopy = this.sourceValue
    }

    navigator.clipboard.writeText(textToCopy).then(() => {
      const originalText = this.copyButtonTarget.textContent
      this.copyButtonTarget.textContent = "Copied!"
      this.copyButtonTarget.classList.add("copied")
      
      setTimeout(() => {
        this.copyButtonTarget.textContent = originalText
        this.copyButtonTarget.classList.remove("copied")
      }, 2000)
    }).catch(err => {
      console.error("Failed to copy:", err)
      alert("Failed to copy to clipboard")
    })
  }
}