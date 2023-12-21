
#define DEBUG_TYPE "function-instantiation"

#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/IRBuilder.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Constants.h"
#include "llvm/Transforms/Utils/Cloning.h"  // Include for CloneFunction
#include "llvm/Support/raw_ostream.h"

using namespace llvm;

namespace {
	class ConstArgFuncOptz : public ModulePass {
		public:
			static char ID;
			ConstArgFuncOptz() : ModulePass(ID) {}

			bool runOnModule(Module &M) override;

		private:
			Function *instantiateFunction(Module &M, Function *originalFunction, CallInst *callInst);
			ConstantInt *createConstantSymbol(Constant *constant);
			void replaceFormalArgumentUses(Function *F, Value *formalArgument, ConstantInt *constantSymbol);
	};
}

char ConstArgFuncOptz::ID = 0;
static RegisterPass<ConstArgFuncOptz> X("function-instantiation", "Function Argument Instantiation Pass");

bool ConstArgFuncOptz::runOnModule(Module &M) {
	for (Function &F : M) {
		for (auto &BB : F) {
			for (auto &I : BB) {
				// Cast the instruction to CallInst
				if (auto *callInst = dyn_cast<CallInst>(&I)) {
					Function *callee = callInst->getCalledFunction();
					if (callee) {
						// Check if the callee is eligible for instantiation
						// You need to implement this function based on your criteria

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

Function *ConstArgFuncOptz::instantiateFunction(Module &M, Function *originalFunction, CallInst *callInst) {
	// Check if any constant arguments are present in the call
	bool hasConstantArgs = false;
	for (unsigned i = 0; i < callInst->getNumArgOperands(); ++i) {
		if (isa<Constant>(callInst->getArgOperand(i))) {
			hasConstantArgs = true;
			break;
		}
	}

	if (!hasConstantArgs) {
		return nullptr;
	}

	// Clone the original function
	ValueToValueMapTy VMap;
	Function *newFunction = CloneFunction(originalFunction, VMap, /*ModuleLevelChanges=*/false);

	// Rename the cloned function to make it unique
	newFunction->setName(originalFunction->getName() + "_inst");

	// Create entry block in the new function
	BasicBlock *entryBB = BasicBlock::Create(M.getContext(), "entry", newFunction);
	IRBuilder<> builder(entryBB);

	// Map between original function arguments and their corresponding constants
	std::map<Value *, Value *> constantArgsMap;

	// Traverse the original function arguments
	for (auto arg = newFunction->arg_begin(), e = newFunction->arg_end(); arg != e; ++arg) {
		// Check if the argument corresponds to a constant in the call
		unsigned argIndex = std::distance(newFunction->arg_begin(), arg);
		if (isa<Constant>(callInst->getArgOperand(argIndex))) {
			// Create a local variable in the entry block for the constant argument
			AllocaInst *allocaInst = builder.CreateAlloca(arg->getType());
			// Create a constant symbol in the main memory
			ConstantInt *constantSymbol = createConstantSymbol(cast<Constant>(callInst->getArgOperand(argIndex)));
			builder.CreateStore(constantSymbol, allocaInst);

			// Map the original argument to the local variable
			constantArgsMap[&*arg] = allocaInst;
		}
	}

	// Replace formal arguments with constant symbols in the new function
	for (auto &entry : constantArgsMap) {
		replaceFormalArgumentUses(newFunction, entry.first, cast<ConstantInt>(entry.second));
	}

	// Create a new call instruction in the entry block
	SmallVector<Value *, 8> newCallArgs;
	for (auto arg = newFunction->arg_begin(), e = newFunction->arg_end(); arg != e; ++arg) {
		newCallArgs.push_back(constantArgsMap.count(&*arg) ? constantArgsMap[&*arg] : &*arg);
	}

	// Create a new call instruction
	CallInst *newCall = builder.CreateCall(newFunction, newCallArgs);
	// newCall->copyMetadata(*callInst);

	// Replace the original call instruction with the new one
	callInst->replaceAllUsesWith(newCall);
	callInst->eraseFromParent();

	return newFunction;
}

ConstantInt *ConstArgFuncOptz::createConstantSymbol(Constant *constant) {
	// Get the type and value of the constant
	IntegerType *intType = dyn_cast<IntegerType>(constant->getType());
	if (!intType) {
		return nullptr; // Cannot create a constant symbol for non-integer types
	}

	uint64_t constantValue = cast<ConstantInt>(constant)->getZExtValue();

	// Create a new constant symbol
	return ConstantInt::get(intType, constantValue);
}

void ConstArgFuncOptz::replaceFormalArgumentUses(Function *F, Value *formalArgument, ConstantInt *constantSymbol) {
	for (auto &BB : *F) {
		for (auto &I : BB) {
			// Replace all uses of the formal argument with the constant symbol
			if (I.getOpcode() != Instruction::PHI) {
				I.replaceUsesOfWith(formalArgument, constantSymbol);
			}
		}
	}
}

