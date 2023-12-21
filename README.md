# LLVM Project - Optimizer Pass

A compiler optimization pass written using LLVM.  

\- Vishal Paudel and Siddharth Sahu  
Siddharth Sahu	-	U20210074  
Vishal Paudel	-	U20210094  

# Directory Structure

final\_submission  
|--- test\_codes	Contains both the unoptimised and optimised bytecodes {example0.bc, example.hello.bc, ...}  
|--- original		Original/Unoptimised IR of the test bytecodes {example0.ll, ...}  
|--- modified		Modified/Optimised Humarn-Readable IR {example0.ll, ...}  
|--- Hello.cpp		Our optimizer pass, the flag is -hello  
|--- others		Libraries & shell-scripts used  
|--- README.md		This file!  

# This project is not too well documented by us

In summary, whenever a function call-site is called with constant actual arguments, the site is replaced by a   
new function call-site that does the same thing but with the constant actual arguments as local variables.  

20 December, 2023
