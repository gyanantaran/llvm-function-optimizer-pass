project_dir="$HOME/llvm-optz-pass-func-O2"
llvm_dir="llvm"
test_codes_dir_name="test_codes"

test_codes_dir_loc="$project_dir/$llvm_dir/$test_codes_dir_name"


# copy over the example files in /srv/shared_directory/llvm/test_codes/ to a local directory in your home directory
cp -R "/srv/shared_directory/llvm/$test_codes_dir_name" "$project_dir/$llvm_dir" || echo "now, test_codes in the home directory"

# Then the output bytecode file (e.g., example1.bc) can be obtained from source code written in C (e.g., example1.c) using:
clang -c -emit-llvm "$test_codes_dir_loc/example1.c" -o ./example1.bc

# This bytecode can be converted to assembly code (e.g., example1.s) using:
llc ./example1.bc -o ./example1.s

# This < output assembly file > can be assembled to an executable (e.g., example1) using gcc-4.8.5:
gcc-4.8 ./example1.s -o ./example1.o

# Run the executable
echo "Running executable, give input"

./example1.o

# We can use llvm-dis to disassemble bytecode to a human readable IR file (e.g., example1.ll)
llvm-dis ./example1.bc -o ./example1.ll

# This human readable IR can be assembled to bytecode using llvm-as as follows
llvm-as ./example1.ll -o ./example1.bc

