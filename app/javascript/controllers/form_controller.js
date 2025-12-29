import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["markdown", "slug", "slugError", "filesContainer"]
  static values = {
    maxFiles: { type: Number, default: 5 },
    maxSize: { type: Number, default: 5242880 } // 5MB
  }

  get allowedFileTypes() {
    return {
      code: ['.js', '.jsx', '.ts', '.tsx', '.py', '.rb', '.html', '.css', '.scss', 
             '.java', '.c', '.cpp', '.h', '.php', '.go'],
      data: ['.json', '.xml', '.yaml', '.yml'],
      text: ['.txt', '.md'],
      images: ['.png', '.jpg', '.jpeg', '.gif', '.svg'],
      documents: ['.pdf', '.pptx', '.docx', '.xlsx'],
      compressed: ['.zip']
    }
  }

  get acceptedTypes() {
    return Object.values(this.allowedFileTypes).flat().join(',')
  }

  connect() {
    this.initializeMarkdownEditor()
  }

  initializeMarkdownEditor() {
    new window.EasyMDE({ 
      element: this.markdownTarget, 
      toolbar: [
        "bold", "italic", "heading-1", "heading-2", "heading-3", "|",
        "code", "quote", "|",
        "unordered-list", "ordered-list", "|",
        "link", "image", "|",
        "preview", "side-by-side", "fullscreen", "|",
        "guide"
      ]
    })
  }

  validateSlug() {
    const regex = /^[a-z0-9\-]+$/
    const slug = this.slugTarget.value
    
    if (!regex.test(slug)) {
      this.showSlugError("Only lowercase letters, numbers and hyphens")
    } else {
      this.clearSlugError()
    }
  }

  showSlugError(message) {
    this.slugErrorTarget.textContent = message
    this.slugTarget.classList.add("error")
  }

  clearSlugError() {
    this.slugErrorTarget.textContent = ""
    this.slugTarget.classList.remove("error")
  }

  addFileField() {
    if (!this.canAddMoreFiles()) {
      alert(`Maximum ${this.maxFilesValue} files allowed`)
      return
    }

    const fileWrapper = this.createFileWrapper()
    this.filesContainerTarget.appendChild(fileWrapper)
  }

  canAddMoreFiles() {
    const currentCount = this.filesContainerTarget.querySelectorAll('input[type="file"]').length
    return currentCount < this.maxFilesValue
  }

  createFileWrapper() {
    const wrapper = document.createElement('div')
    wrapper.classList.add('file-input-wrapper')

    const input = this.createFileInput()
    const fileName = this.createFileNameDisplay()
    const removeButton = this.createRemoveButton(wrapper)

    this.attachFileValidation(input, fileName)

    wrapper.appendChild(input)
    wrapper.appendChild(fileName)
    wrapper.appendChild(removeButton)

    return wrapper
  }

  createFileInput() {
    const input = document.createElement('input')
    input.setAttribute("type", "file")
    input.setAttribute("name", "share[files][]")
    input.setAttribute("accept", this.acceptedTypes)
    return input
  }

  createFileNameDisplay() {
    const span = document.createElement('span')
    span.classList.add('file-name')
    return span
  }

  createRemoveButton(wrapper) {
    const button = document.createElement('button')
    button.type = "button"
    button.textContent = "Remove"
    button.classList.add('remove-file')
    button.addEventListener('click', () => wrapper.remove())
    return button
  }

  attachFileValidation(input, fileNameDisplay) {
    input.addEventListener('change', (event) => {
      const file = event.target.files[0]
      if (!file) return

      if (!this.validateFileSize(file)) {
        this.clearFileInput(input, fileNameDisplay)
        return
      }

      this.displayFileName(file, fileNameDisplay)
    })
  }

  validateFileSize(file) {
    if (file.size > this.maxSizeValue) {
      const maxSizeMB = this.maxSizeValue / 1024 / 1024
      alert(`File "${file.name}" is too large. Maximum size is ${maxSizeMB}MB.`)
      return false
    }
    return true
  }

  clearFileInput(input, fileNameDisplay) {
    input.value = ''
    fileNameDisplay.textContent = ''
  }

  displayFileName(file, fileNameDisplay) {
    const sizeMB = (file.size / 1024 / 1024).toFixed(2)
    fileNameDisplay.textContent = `${file.name} (${sizeMB} MB)`
  }
}