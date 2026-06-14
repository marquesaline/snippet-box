// app/javascript/controllers/share_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rendered", "raw", "renderedButton", "rawButton", "copyButton"]
  static values = { source: String }

  connect() {
    this.showRendered()
    this.addCodeCopyButtons()
  }

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

  addCodeCopyButtons() {
    this.renderedTarget.querySelectorAll("pre:not(.has-copy-btn)").forEach((pre) => {
      pre.classList.add("has-copy-btn")

      const btn = document.createElement("button")
      btn.textContent = "Copy"
      btn.className = "code-copy-btn"
      btn.type = "button"
      btn.setAttribute("aria-label", "Copy code to clipboard")

      btn.addEventListener("click", () => {
        const code = pre.querySelector("code")
        navigator.clipboard.writeText(code ? code.textContent : "").then(() => {
          btn.textContent = "Copied!"
          btn.classList.add("copied")
          setTimeout(() => {
            btn.textContent = "Copy"
            btn.classList.remove("copied")
          }, 2000)
        })
      })

      pre.appendChild(btn)
    })
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