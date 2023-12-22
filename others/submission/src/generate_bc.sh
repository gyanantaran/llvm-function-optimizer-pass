#!/bin/bash

# Set the source and destination directories with absolute paths
src_dir=$(realpath ../../llvm/test_codes/Function-inlining)
dest_dir=$(realpath ../input/test_bc/Function-inlining)

# Create the destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Add the llvm installation to the PATH
export PATH="/srv/shared_directory/llvm/3.4-install/install/bin/:$PATH"

# Loop through all C files in the source directory
for file in "$src_dir"/*.c; do
	if [ -f "$file" ]; then
		# Get the file name without extension
		filename=$(basename -- "$file")
		filename_noext="${filename%.*}"

		# Generate the destination path for the LLVM bitcode file
		dest_path=$(realpath "$dest_dir/$filename_noext.bc")

		# Print the clang command
		echo "clang -c -emit-llvm $file -o $dest_path"

		# Run clang to compile the C file to LLVM bitcode
		clang -c -emit-llvm "$file" -o "$dest_path"


		echo "Compiled $filename to $dest_path"
	fi
done

