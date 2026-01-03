# SnippetBox

A web platform for quick code, text and file sharing, initially designed for educational contexts (teachers sharing materials with students).

🌐 **Live Demo:** [snippet-box.com](https://www.snippet-box.com/)

---

## ✨ Features

- **Markdown Support** with syntax highlighting (via Toast UI Editor)
- **File Uploads** (up to 5 files, 5MB each)
- **Custom URLs** or auto-generated slugs
- **Cookie-based Editing** (30 days)
- **Auto-expiration** (shares expire after 30 days)
- **No account required**
---

## 🛠️ Tech Stack

**Backend:**
- Ruby 3.2.9
- Rails 8.0
- PostgreSQL 16
- Active Storage (file handling)
- Solid Queue (background jobs)

**Frontend:**
- Hotwire (Turbo + Stimulus)
- Sass
- Toast UI Editor
- Kramdown + Rouge (Markdown rendering)

**Infrastructure:**
- Docker + Docker Compose
- Railway (production)

---

## 🚀 Getting Started

### Prerequisites

- Docker
- Docker Compose


### Quick Start
```bash
# Clone the repository
git clone https://github.com/marquesaline/snippet-box.git
cd snippet-box

# Start everything (auto-installs dependencies, runs migrations, starts server + Sass)
docker compose up --build
```

Access the application at: **http://localhost:3001**

---

### Testing

```bash
# Run all tests
docker compose exec app bin/rails test

# Run specific test files
docker compose exec app bin/rails test test/controllers/shares_controller_test.rb
docker compose exec app bin/rails test test/models/share_test.rb

# Run with coverage
docker compose exec app bin/rails test
```

---

### Code Quality

```bash
# Auto-fix style violations (RuboCop)
docker compose exec app bundle exec rubocop -A

# Check style without fixing
docker compose exec app bundle exec rubocop
```

---
## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

Made by Aline Marques. Feel free to contribute.
