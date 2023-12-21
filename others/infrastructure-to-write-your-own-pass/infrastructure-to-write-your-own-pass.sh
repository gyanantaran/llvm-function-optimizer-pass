LLVM_DIR="/srv/shared_directory/llvm"

USER_NAME="vishal.paudel@plaksha.edu.in"
PROJ_DIR="/home/$USER_NAME/llvm-optz-pass-func-O2/infrastructure-to-write-your-own-pass"
SAMPLE_DIR="$PROJECT_DIR/llvm/sample"


LLVM_SRC="/srv/shared_directory/llvm/3.4-install/src/llvm"
LLVM_OBJ="/srv/shared_directory/llvm/3.4-install/build"








# (1) First copy the sample directory present at /srv/shared_directory/llvm/sample to your local directory, say ~/xyz/sample. 
if [ -d xyz ]; then
		rm -r xyz
else
	mkdir xyz
fi

cd xyz
cp -R "/srv/shared_directory/llvm/sample" "." && echo "now, sample in the home directory"









# (2) create two directories
# (i) obj directory and (ii) an install directory
mkdir obj
mkdir opt










# (3) Configure the build system in the obj directory as follows:
cd ./obj
#../sample/configure --with-llvmsrc="$LLVM_SRC" --with-llvmobj="$LLVM_OBJ" --prefix="$PROJECT_DIR/xyz/opt"


















# (4) You can build it and test it out as follows:
make install

















# (5) Set the PATH variable to also have the llvm installation as follows:
llvm_path="/srv/shared_directory/llvm/3.4-install/install/bin"
if [[ ":$PATH:" != *":$llvm_path:"* ]]; then
	export PATH="$llvm_path:$PATH"
	echo "LLVM installation directory added to PATH"
else
	echo "LLVM installation directory is already in PATH."
fi

# Check that the installation is correct as follows
cd ./obj
opt --version 
cd -


















# (6) You can run your pass as follows:
cd ./obj
#opt -load ../opt/lib/libHello.so -hello ../test_codes/example1.bc -o ../example1.hello.bc
opt -load ../opt/lib/libHelloArguments.so -helloarguments ../test_codes/example1.bc -o ../example1.helloarguments.bc
cd -

# This bytecode can be converted to assembly code (e.g., example1.s) using:
#llc ./example1.hello.bc -o ./example1.hello.s
llc ./example1.helloarguments.bc -o ./example1.helloarguments.s

# This < output assembly file > can be assembled to an executable (e.g., example1) using gcc-4.8.5:
#gcc-4.8 ./example1.hello.s -o ./example1.hello.o
gcc-4.8 ./example1.helloarguments.s -o ./example1.helloarguments.o

# Run the executable
echo "Running executable, give input"

#./example1.hello.o
./example1.helloarguments.o
