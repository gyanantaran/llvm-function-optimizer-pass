#!/usr/bin/env bash

# Set the directory containing test bytecode files
TEST_BC_DIR="./test_bc/Function-inlining/"

# Set the directory to store the optimized bytecode files
OPTZ_BC_DIR="./optz_bc"


# Create the IR output directory if it doesn't exist
mkdir -p "$OPTZ_BC_DIR"

# Find all '.bc' files in the bytecode directory
BC_FILES=$(find "$TEST_BC" -name '*.bc')

# Loop through each '.bc' file and generate optimized bytecode
for BC_FILE in $BC_FILES; do
	# Extract the filename without the extension
	FILENAME=$(basename "$BC_FILE" .bc)



	# Check if the IR generation was successful
	if [ $? -eq 0 ]; then
		echo "BC optimized for $FILENAME.bc"
	else
		echo "Error optimizing BC for $FILENAME.bc"
	fi
done

