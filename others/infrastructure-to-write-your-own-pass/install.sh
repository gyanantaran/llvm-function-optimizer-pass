# change directory to obj
cd xyz/obj

# Build and install
make install

# Set the PATH variable to also have the llvm installation
export PATH=/srv/shared_directory/llvm/3.4-install/install/bin/:$PATH

# Run mypass
# segmentation fault: opt -load ../opt/lib/libConstArgFuncOptz.so -function-instantiation /srv/shared_directory/llvm/test_codes/example1.bc -o ../../example1.function-instantiation-optz.bc
#opt -load ../opt/lib/libFunctionInstantiationPass.so -function-instantiation /srv/shared_directory/llvm/test_codes/example1.bc -o ../../example1.function-instantiation.bc
#opt -load ../opt/lib/libHelloArguments.so -helloarguments /srv/shared_directory/llvm/test_codes/example1.bc -o example1.helloarguments.bc
opt -load ../opt/lib/libHello.so -hello /srv/shared_directory/llvm/test_codes/example1.bc -o ./example1.hello.bc
