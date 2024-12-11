render_book_slides <- function(...) {

  # copy the file _quarto_book.yml to _quarto.yml
  file.copy("_quarto_book.yml", "_quarto.yml", overwrite = T)
  # render the book
  quarto::quarto_render(..., as_job = FALSE)
 
  # copy the file 
  file.copy("_quarto_slides.yml", "_quarto.yml", overwrite = T)
  quarto::quarto_render(..., as_job = FALSE)
  
  
  file.copy("_quarto_practicals.yml", "_quarto.yml", overwrite = T)
  quarto::quarto_render(..., as_job = FALSE)

  
  
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
  
  
  ## As above, copy all the csv files in the practicals folder to the docs/practicals folder
  
  # Define the directory to search
  source_dir <- "practicals/"
  # Specify the file extension to copy (e.g., ".csv")
  file_extension <- ".csv"
  # Get a list of all files with the specified extension
  csv_files <- list.files(source_dir, pattern = file_extension)
  # Destination directory where you want to copy the files
  dest_dir <- "docs/practicals/"
  # copy the files to the destination directory
  file.copy(file.path(source_dir, csv_files), dest_dir, overwrite = TRUE)
  
  
}

render_book_slides()





