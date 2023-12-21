#!/bin/bash
# you have to be in the same directory as the script
# that is you have to be inside the src directory

generate_ir() {
	local bytecode_dir="$1"
	local ir_dir="$2"

	# Create the IR output directory if it doesn't exist
	mkdir -p "$ir_dir"

	# Find all '.bc' files in the bytecode directory
	bc_files=$(find "$bytecode_dir" -name '*.bc')

	# Loop through each '.bc' file and generate human-readable IR
	for bc_file in $bc_files; do
		# Extract the filename without the extension
		filename=$(basename "$bc_file" .hello.bc)

		# Generate human-readable IR using llvm-dis
		llvm-dis "$bc_file" -o "$ir_dir/$filename.ll"

		# Check if the IR generation was successful
		if [ $? -eq 0 ]; then
			echo "IR generated for $bc_file"
		else
			echo "Error generating IR for $bc_file"
		fi
	done
}

# Example usage:
#generate_ir "../input/test_bc" "../output/test_ir_output"
generate_ir "../output/optz_bc" "../output/optz_ir_output"

