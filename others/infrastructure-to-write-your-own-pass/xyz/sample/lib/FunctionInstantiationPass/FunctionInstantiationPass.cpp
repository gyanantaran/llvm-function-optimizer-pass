
#define DEBUG_TYPE "function-instantiation"

#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
	class FunctionInstantiationPass : public ModulePass {
		public:
			static char ID;
			FunctionInstantiationPass() : ModulePass(ID) {}

			bool runOnModule(Module &M) override;

		private:
			Function *instantiateFunction(Module &M, Function *originalFunction, CallInst *callInst);
	};
}

char FunctionInstantiationPass::ID = 0;
static RegisterPass<FunctionInstantiationPass> X("function-instantiation", "Function Argument Instantiation Pass");

bool FunctionInstantiationPass::runOnModule(Module &M) {
	printf("Hello\n");
	for (Function &F : M) {
		for (auto &BB : F) {
			for (auto &I : BB) {
				if (auto *callInst = dyn_cast<CallInst>(&I)) {
					Function *callee = callInst->getCalledFunction();
					if (callee) {
						// Check if the callee is eligible for instantiation
						// I need to implement this function based on your criteria

						// If eligible, create a new function and replace the call
						Function *newFunction = instantiateFunction(M, callee, callInst);
						if (newFunction) {
							errs() << "Function instantiated: " << newFunction->getName() << "\n";
						}
					}
				}
			}
		}
	}

	return true;
}

Function *FunctionInstantiationPass::instantiateFunction(Module &M, Function *originalFunction, CallInst *callInst) {
	// Check if any constant arguments are present in the call
	bool hasConstantArgs = false;
	for (unsigned i = 0; i < callInst->getNumArgOperands(); ++i) {
		if (isa<ConstantInt>(callInst->getArgOperand(i))) {
			hasConstantArgs = true;
			break;
		}
	}

	if (!hasConstantArgs) {
		return nullptr;
	}

	// Create a new function with a unique name
	FunctionType *FTy = originalFunction->getFunctionType();
	Function *newFunction = Function::Create(FTy, GlobalValue::InternalLinkage, originalFunction->getName() + "_inst", &M);

	// Copy attributes, metadata, etc., from the original function to the new one
	newFunction->copyAttributesFrom(originalFunction);

	// Create entry block in the new function
	BasicBlock *entryBB = BasicBlock::Create(M.getContext(), "entry", newFunction);
	IRBuilder<> builder(entryBB);

	// Map between original function arguments and their corresponding constants
	std::map<Value *, Value *> constantArgsMap;


	// Traverse the original function arguments
	for (unsigned i = 0; i < originalFunction->arg_size(); ++i) {
		Argument *arg = &*(std::next(newFunction->arg_begin(), i));

		// Check if the argument corresponds to a constant in the call
		if (isa<ConstantInt>(callInst->getArgOperand(i))) {
			// Create a local variable in the entry block for the constant argument
			AllocaInst *allocaInst = builder.CreateAlloca(arg->getType());
			builder.CreateStore(callInst->getArgOperand(i), allocaInst);

			// Map the original argument to the local variable
			constantArgsMap[arg] = allocaInst;
		}
	}

	// Create a new call instruction in the entry block
	SmallVector<Value *, 8> newCallArgs;
	for (Function::arg_iterator arg = newFunction->arg_begin(); arg != newFunction->arg_end(); ++arg) {
		newCallArgs.push_back(constantArgsMap.count(arg) ? constantArgsMap[arg] : arg);
	}

	CallInst *newCall = builder.CreateCall(newFunction, newCallArgs);
	// manually copying meta-data
	for (unsigned i = 0; i < callInst->getNumOperands(); ++i) {
		    newCall->setMetadata(callInst->getOperand(i)->getName(), callInst->getMetadata(i));
	}

	// Erase the original call instruction
	callInst->eraseFromParent();

	return newFunction;
}

