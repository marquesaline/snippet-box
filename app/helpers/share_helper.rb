module ShareHelper
  def can_edit?(share)
    cookies["owner_#{share.slug}"] == share.edit_token
  end

  def render_markdown(text)
    return "" if text.blank?

    Kramdown::Document.new(
      text,
      input: "GFM",
      syntax_highlighter: "rouge"
    ).to_html.html_safe
  end

  def extract_title_from_markdown(content)
    return nil if content.blank?
    match = content.match(/\A\s*#\s+(.+)$/)
    match&.captures&.first&.strip
  end

  def language_label(lang)
    {
      "rb" => "Ruby", "ruby" => "Ruby",
      "js" => "JavaScript", "javascript" => "JavaScript",
      "ts" => "TypeScript", "typescript" => "TypeScript",
      "py" => "Python", "python" => "Python",
      "go" => "Go",
      "rs" => "Rust", "rust" => "Rust",
      "java" => "Java",
      "cs" => "C#",
      "cpp" => "C++", "c" => "C",
      "html" => "HTML", "css" => "CSS", "scss" => "SCSS",
      "sql" => "SQL",
      "sh" => "Shell", "bash" => "Shell",
      "json" => "JSON", "yaml" => "YAML", "yml" => "YAML",
      "md" => "Markdown", "markdown" => "Markdown",
      "php" => "PHP",
      "swift" => "Swift", "kotlin" => "Kotlin",
      "dockerfile" => "Dockerfile"
    }.fetch(lang, lang.upcase)
  end

  def file_icon(filename)
    extension = File.extname(filename).downcase

    case extension
    when ".pdf"
      "📄"
    when ".doc", ".docx"
      "📝"
    when ".xls", ".xlsx", ".csv"
      "📊"
    when ".zip", ".rar", ".7z", ".tar", ".gz"
      "📦"
    when ".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg"
      "🖼️"
    when ".mp4", ".avi", ".mov", ".mkv"
      "🎬"
    when ".mp3", ".wav", ".ogg"
      "🎵"
    when ".txt", ".md"
      "📃"
    when ".js", ".jsx", ".ts", ".tsx"
      "📜"
    when ".rb", ".py", ".java", ".cpp", ".c", ".go", ".rs"
      "💻"
    when ".html", ".css", ".scss"
      "🌐"
    when ".json", ".xml", ".yaml", ".yml"
      "⚙️"
    else
      "📎"
    end
  end
end
