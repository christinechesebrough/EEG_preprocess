# Load the required libraries
library(dplyr)
library(purrr)
library(readr)

# Set the directory path where the CSV files are located
directory_path <- '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_ratings/MW_ratings4'

# Set the directory path where the processed CSV files will be saved
output_directory_path <- '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_ratings/MW_ratings_processed_FreelyMoving_noZ'

# Create the output directory if it doesn't exist
if (!dir.exists(output_directory_path)) {
  dir.create(output_directory_path)
}

# Get a list of all CSV files in the directory
csv_files <- list.files(path = directory_path, pattern = '\\.csv', full.names = TRUE)

# Function to process each CSV file
processRatings <- function(file_path) {
  # Read the CSV file without changing the column names
  data <- read_csv(file_path, show_col_types = FALSE, col_names = TRUE)
  
  # Replace spaces with dots in column names to standardize
  names(data) <- gsub(" ", ".", names(data))
  
  # Check if 'Confidence' column exists
  if ("Confidence" %in% names(data)) {
    # Set entire row to NA if 'Confidence' value is greater than 80
    data <- data %>%
      mutate(across(everything(), ~if_else(Confidence > 80, NA_real_, .)))
  } else {
    warning("Column 'Confidence' does not exist in file: ", file_path)
  }
  
  # Check if 'Freely.Moving' column exists
  if ("Freely.Moving" %in% names(data)) {
    # Replace 101 with NA across all applicable columns
    data <- data %>%
      mutate(across(everything(), ~na_if(., 101)))
    
    # Retain only the 'Freely.Moving' column
    data <- data %>%
      select(Freely.Moving)
    
    # Transform the 'Freely Moving' column
    data$Freely.Moving <- case_when(
      data$Freely.Moving > 50 ~ "freely",
      data$Freely.Moving < 50 ~ "unmoving",
      TRUE ~ NA_character_
    )
  } else {
    warning("Column 'Freely.Moving' does not exist in file: ", file_path)
  }
  
  # Extract the first three characters of the filename
  subject_folder <- substr(basename(file_path), 1, 3)
  
  # Create a new directory for this subject if it doesn't exist
  subject_directory_path <- file.path(output_directory_path, subject_folder)
  if (!dir.exists(subject_directory_path)) {
    dir.create(subject_directory_path)
  }
  
  # Define a new file name for saving
  new_file_name <- gsub('\\.csv', '_processed_freelymoving_noZ.csv', basename(file_path))
  
  # Save the modified data to the new CSV file in the subject-specific directory
  write_csv(data, file.path(subject_directory_path, new_file_name), col_names = FALSE)
  
  # Print a message for each file processed
  cat("Processed and saved", file_path, "as", file.path(subject_directory_path, new_file_name), "\n")
}

# Apply the processing function to each CSV file
walk(csv_files, processRatings)

