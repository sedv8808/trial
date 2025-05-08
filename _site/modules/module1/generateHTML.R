generateHTML <- function(html_file) {
  html_content <- readLines(html_file, warn = FALSE)
  # Find the base directory
  base_dir <- dirname(html_file)
  # Function to inline CSS and JS
  inline_dependency <- function(line) {
    # Inline CSS
    if (grepl('href="', line)) {
      css_path <- sub('.*href="([^"]+)".*', '\\1', line)
      full_path <- file.path(base_dir, css_path)
      if (file.exists(full_path)) {
        css_content <- paste(readLines(full_path), collapse = "\n")
        return(sprintf("<style>%s</style>", css_content))
      }
    }
    # Inline JS
    if (grepl('src="', line)) {
      js_path <- sub('.*src="([^"]+)".*', '\\1', line)
      full_path <- file.path(base_dir, js_path)
      if (file.exists(full_path)) {
        js_content <- paste(readLines(full_path), collapse = "\n")
        return(sprintf("<script>%s</script>", js_content))
      }
    }
    return(line)
  }
  # Process the HTML
  inlined_html <- sapply(html_content, inline_dependency)
  final_html <- paste(inlined_html, collapse = "\n")
  base64_encoded_html <- base64enc::base64encode(charToRaw(final_html))
  return(base64_encoded_html)
}