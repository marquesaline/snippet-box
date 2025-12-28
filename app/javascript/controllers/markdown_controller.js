import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    new window.EasyMDE({ 
      element: this.element, 
      toolbar: [
        "bold", "italic", "heading", "|",
        "code", "quote", "|",
        "unordered-list", "ordered-list", "|",
        "link", "image", "|",
        "preview", "side-by-side", "fullscreen", "|",
        "guide"
      ]
    })
  }
}