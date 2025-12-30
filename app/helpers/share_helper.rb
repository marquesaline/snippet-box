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
end
