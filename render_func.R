render_book_slides <- function(...) {
  # 1. Render the book
  quarto::quarto_render(as_job = FALSE)
  
  # 2. Render all slides using the slides sub-project
  quarto::quarto_render(input = "slides", as_job = FALSE)
  
  # 3. Render practicals using the practicals profile
  quarto::quarto_render(profile = "practicals", as_job = FALSE)
  
  # 4. Copy static assets (PDFs and CSVs)
  copy_assets <- function(from_dir, to_dir, ext) {
    files <- list.files(from_dir, pattern = paste0("\\", ext, "$"), full.names = TRUE)
    dir.create(to_dir, recursive = TRUE, showWarnings = FALSE)
    file.copy(files, to_dir, overwrite = TRUE)
  }
  
  copy_assets("slides", "docs/slides", ".pdf")
  copy_assets("slides", "docs/slides", ".csv")
  copy_assets("practicals", "docs/practicals", ".pdf")
  copy_assets("practicals", "docs/practicals", ".csv")
}