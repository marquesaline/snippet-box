# SnippetBox

A web platform for quick code and file sharing, initially designed for educational contexts (teachers sharing materials with students).

## 🚀 Getting Started

### Prerequisites

- Docker
- Docker Compose

### Initial Setup

1. **Start the containers**
```bash
   docker-compose up -d
```

2. **Enter the app container**
```bash
   docker-compose exec app bash
```

3. **Install dependencies**
```bash
   bundle install
```

4. **Create and setup the database**
```bash
   rails db:create
   rails db:migrate
```

5. **Start the Rails server**
```bash
   rails server -b 0.0.0.0 -p 3001
```

6. **Access the application**
   
   Open your browser at: http://localhost:3001

---