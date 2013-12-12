REGEX_PATTERN = {
  :email => /\A[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}\z/,
  :name => /\A[a-zA-Z]+([\s][a-zA-Z]+){0,2}\z/,
  :category_name => /\A[[:alnum:]]+[\w\s[:punct:]]+\z/
}