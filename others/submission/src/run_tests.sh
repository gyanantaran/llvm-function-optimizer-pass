#!/usr/bin/env bash

set -e  # Exit on error

# Define variables for better readability
OBJ_DIR="$(realpath ../../infrastructure-to-write-your-own-pass/xyz/obj)"
INPUT_BC_DIR="$(realpath ../input/test_bc/Function-inlining)"
OUTPUT_BC_DIR="$(realpath ../output/optz_bc/Function-inlining)"

#PASS_NAME="-function-instantiation"
PASS_NAME="-hello"

# Change directory to obj
cd "$OBJ_DIR" || exit
pwd

# Build and install
make install

# Add the llvm installation to the PATH
export PATH="/srv/shared_directory/llvm/3.4-install/install/bin/:$PATH"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_BC_DIR"

# Run mypass on all '.bc' files in INPUT_BC_DIR
for bc_file in "$INPUT_BC_DIR"/*.bc; do
	# Extract the filename without the extension
	filename=$(basename "$bc_file" .bc)

	# Run mypass on the current '.bc' file
	output_file="$OUTPUT_BC_DIR/$filename.hello.bc"

	output_file=$(realpath $output_file)
	bc_file=$(realpath $bc_file)
	if [[ -f "$bc_file" ]]; then
		#opt -load ../opt/lib/libFunctionInstantiationPass.so "$PASS_NAME" "$bc_file" -o "$output_file"
		opt -load ../opt/lib/libHello.so "$PASS_NAME" "$bc_file" -o "$output_file"

		# Check if the opt command was successful
		if [ $? -eq 0 ]; then
			echo "Optimization completed for $filename.bc"
		else
			echo "Error optimizing $filename.bc. Check the input file."
		fi
	else
		echo "Error: Input file $bc_file not found."
	fi
done
echo "Finished Generating bytcode for all files"
