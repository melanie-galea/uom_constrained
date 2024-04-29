#!/bin/bash

# Go to the directory containing the DeepSpeech executable
cd DeepSpeech

rm ../result_masri.mt
pip3 install deepspeech-gpu

# Define the directory containing the WAV files
directory="./test-mt/masri"

# Define the CSV file containing the order
csv_file="./test-mt/masri/masri_test.csv"

# Define the output file
output_file="../result_masri.mt"

# Check if the CSV file exists
if [ ! -f "$csv_file" ]; then
    echo "Error: CSV file $csv_file not found."
    exit 1
fi

# Loop through each line in the CSV file to process WAV files in the specified order
while IFS= read -r line; do
    # Remove any '\r' characters from the line (if present)
    filename=$(echo "$line" | tr -d '\r')
    echo $directory/$filename
    
    # Run deepspeech command for the current file
    deepspeech --audio "$directory/$filename.wav" --model ./exported/output_graph.pb > tmp_masri.out
    
    echo "tmp_masri.out"
    cat tmp_masri.out
    
    # Get the second-to-last line from tmp.out and append it to result.mt
    tail -n 2 tmp_masri.out | head -n 1 >> "$output_file"
done < "$csv_file"

# Cleanup temporary file
rm tmp_masri.out