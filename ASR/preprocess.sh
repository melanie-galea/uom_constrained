#!/bin/bash

# Function to count the number of .wav files in a directory
count_wav_files() {
    local input_folder="$1"
    local total_files=0
    for speaker_dir in "$input_folder"/*; do
        if [ -d "$speaker_dir" ]; then
            files_in_speaker_dir=$(find "$speaker_dir" -maxdepth 1 -type f -name "*.wav" | wc -l)
            total_files=$((total_files + files_in_speaker_dir))
        fi
    done
    echo "$total_files"
}

# Function to clean text: convert to lowercase 
clean_text() {
    local text="$1"
    text=$(echo "$text" | tr '[:upper:]' '[:lower:]') # Convert to lowercase
    echo "$text"
}

# Function to process and update CSV files
process_csv() {
    local csv_file="$1"
    local output_csv_file="$2"
    local column_index="$3"
    local csv_temp_file=$(mktemp)
    
    # Read CSV file, clean specified column, and save to temporary file
    while IFS=, read -r col1 col2 col3; do
        cleaned_text=$(clean_text "$col3")
        echo "$col1,$col2,$cleaned_text" >> "$csv_temp_file"
    done < "$csv_file"
    
    # Move cleaned data back to original CSV file
    mv "$csv_temp_file" "$output_csv_file"
}

# Function to update filenames in CSV file with directory prefix
update_csv_filenames() {
    local csv_file="$1"
    local directory_prefix="$2"
    sed -i "s|^wav_filename|${directory_prefix}wav_filename|g" "$csv_file"
}

# Function to copy audio files to a new folder
copy_audio_files() {
    local base_folder="$1"
    local gender_folders=("female" "male")
    local new_audio_folder="/path/to/new/folder"
    
    mkdir -p "$new_audio_folder" # Create new folder if it doesn't exist
    
    for gender in "${gender_folders[@]}"; do
        input_folder="$base_folder/$gender"
        for speaker_dir in "$input_folder"/*; do
            if [ -d "$speaker_dir" ]; then
                cp -v "$speaker_dir"/*.wav "$new_audio_folder" # Copy .wav files to new folder
            fi
        done
    done
}

# Count .wav files in 'audio files' directory
base_folder="/path/to/base/folder"
total_files=$(count_wav_files "$base_folder")
echo "Total number of .wav files in 'audio files' directory: $total_files"

# Copy audio files to a new folder
copy_audio_files "/path/to/base/folder"
echo "All audio files copied successfully!"

# Clean transcript column in CSV file
csv_file="/path/to/csv"
output_csv_file="/path/to/new.csv"
process_csv "$csv_file" "$output_csv_file" 3
echo "CSV file cleaned successfully!"

# Update filenames in CSV file with directory prefix
csv_filename="/path/to/csv"
directory_prefix="/path/to/clips/folder"
update_csv_filenames "$csv_filename" "$directory_prefix"
echo "Filenames in CSV file updated successfully!"


