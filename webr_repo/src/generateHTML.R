library(neotoma2)
library(htmlwidgets)
library(leaflet)
options(warn = -1)

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
  full_html <- paste(
    "<!DOCTYPE html>",
    "<html>",
    "<head>",
    "<meta charset='UTF-8'>",
    "<title>Embedded HTML</title>",
    "</head>",
    "<body>",
    final_html,
    "</body>",
    "</html>",
    sep = "\n"
  )
  base64_encoded_html <- base64enc::base64encode(charToRaw(full_html))
  return(base64_encoded_html)
}

plotLeaflet <- function(sites) {
  map <- neotoma2::plotLeaflet(sites)
  html_file <- tempfile(fileext = ".html")
  htmlwidgets::saveWidget(map, html_file, selfcontained = FALSE)
  ht <- generateHTML(html_file)
  cat(sprintf('<iframe src="data:text/html;base64,%s"
               width="50%%" height="300"></iframe>', ht))
}