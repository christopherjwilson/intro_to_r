render_book_slides <- function(...) {
  quarto::quarto_render(..., as_job = FALSE)
  file.rename("_quarto.yml", "_quarto_book.yml")
  file.rename("_quarto_slides.yml", "_quarto.yml")
  on.exit(file.rename("_quarto.yml", "_quarto_slides.yml"))
  on.exit(file.rename("_quarto_book.yml", "_quarto.yml"), add = TRUE)
  quarto::quarto_render(..., as_job = FALSE)
}

render_book_slides()

## copy all pdf files from slides to docs/slides
# Define the directory to search

source_dir <- "slides/"
# Specify the file extension to copy (e.g., ".pdf")

file_extension <- ".pdf"

# Get a list of all files with the specified extension

pdf_files <- list.files(source_dir, pattern = file_extension)

# Destination directory where you want to copy the files

dest_dir <- "docs/slides/"

# copy the files to the destination directory

file.copy(file.path(source_dir, pdf_files), dest_dir, overwrite = TRUE)





