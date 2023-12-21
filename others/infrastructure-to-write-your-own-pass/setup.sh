#!/bin/bash

LLVM_SRC="/srv/shared_directory/llvm/3.4-install/src/llvm"
LLVM_OBJ="/srv/shared_directory/llvm/3.4-install/build"
USER_NAME="vishal.paudel@plaksha.edu.in"

PROJ_DIR="/home/$USER_NAME/llvm-optz-pass-func-O2/infrastructure-to-write-your-own-pass"

if [ -d xyz ]; then
		rm -r xyz
fi

mkdir xyz
mkdir xyz/obj
mkdir xyz/opt

cd xyz
cp -r "$PROJ_DIR/../llvm/sample" .

cd obj

# Configure the build system
../sample/configure --with-llvmsrc="$LLVM_SRC" --with-llvmobj="$LLVM_OBJ" --prefix="$PROJ_DIR/xyz/opt"

# Build and install
make install

# Set the PATH variable to also have the llvm installation
export PATH=/srv/shared_directory/llvm/3.4-install/install/bin/:$PATH

# Run the test pass
opt -load ../opt/lib/libHello.so -hello /srv/shared_directory/llvm/test_codes/example1.bc -o example1.hello.bc
