module ProjectsHelper

  def raw_sanitized_text(text)
    raw sanitize(text, attributes: %w'style class id')
  end

end