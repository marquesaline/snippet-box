module ShareHelper
  def can_edit?(share)
    cookies["owner_#{share.slug}"] == share.edit_token
  end

  def render_markdown(text)
    return "" if text.blank?

    Kramdown::Document.new(
      text,
      input: "GFM",  # GitHub Flavored Markdown
      syntax_highlighter: "rouge"
    ).to_html.html_safe
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
