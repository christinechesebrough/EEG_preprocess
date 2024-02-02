# Load the required libraries
library(dplyr)
library(purrr)
library(readr)

# Set the directory path where the CSV files are located
directory_path <- '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_ratings4'

# Set the directory path where the processed CSV files will be saved
output_directory_path <- '/Users/christinechesebrough/Documents/MW_EEG_dir/MW_ratings_processed_attention_z'

# Create the output directory if it doesn't exist
if (!dir.exists(output_directory_path)) {
  dir.create(output_directory_path)
}

# Get a list of all CSV files in the directory
csv_files <- list.files(path = directory_path, pattern = '\\.csv', full.names = TRUE)

# Function to process each CSV file
processRatings_z <- function(file_path) {
  # Read the CSV file
  data <- read_csv(file_path)
  
  # Check if 'Confidence' column exists
  if ("Confidence" %in% names(data)) {
    # Set entire row to NA if 'Confidence' value is greater than 80
    data <- data %>%
      mutate(across(everything(), ~if_else(Confidence > 85, NA_real_, .)))
  } else {
    warning("Column 'Confidence' does not exist in file: ", file_path)
  }
  
  # Retain only the 'Attention' column and replace 101 with NA
  data <- data %>%
    select(Attention) %>%
    mutate(across(everything(), ~na_if(., 101)))
  
  # Calculate the z-score for the 'Attention' column
  data <- data %>%
    mutate(Attention = ifelse(is.na(Attention), NA_real_, (Attention - mean(Attention, na.rm = TRUE)) / sd(Attention, na.rm = TRUE)))
  
  # Relabel the 'Attention' column based on the z-score
  data$Attention <- case_when(
    data$Attention > 0 ~ "mental",
    data$Attention < 0 ~ "physical",
    TRUE ~ NA_character_
  )
  
  colnames(data)<-NULL
  
  # Extract the first three characters of the filename
  subject_folder <- substr(basename(file_path), 1, 3)
  
  # Create a new directory for this subject if it doesn't exist
  subject_directory_path <- file.path(output_directory_path, subject_folder)
  if (!dir.exists(subject_directory_path)) {
    dir.create(subject_directory_path)
  }
  
  # Define a new file name for saving
  new_file_name <- gsub('\\.csv', '_processed_attn_z.csv', basename(file_path))
  
  # Save the modified data to the new CSV file in the subject-specific directory
  write_csv(data, file.path(subject_directory_path, new_file_name), col_names = FALSE)
  
  # Print a message for each file processed
  cat("Processed and saved", file_path, "as", file.path(subject_directory_path, new_file_name), "\n")
}

# Apply the processing function to each CSV file
walk(csv_files, processRatings_z)
