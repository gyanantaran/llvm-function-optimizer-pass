#define DEBUG_TYPE "hello"
#include <stack>
#include <set>
#include <llvm/Transforms/Utils/Cloning.h>
#include <llvm/IR/LLVMContext.h>
#include <llvm/IR/Module.h>
#include <llvm/IRReader/IRReader.h>
#include <llvm/Pass.h>
#include <llvm/Support/raw_ostream.h>
#include <llvm/Support/SourceMgr.h>
#include <llvm/Transforms/Utils/BasicBlockUtils.h>
#include <llvm/IR/Function.h>
#include <llvm/IR/Instruction.h>
#include <llvm/IR/Instructions.h>

using namespace llvm;

namespace
{
	class FuncParamProcessorPass : public ModulePass
	{
	public:
		static char ID;
		FuncParamProcessorPass() : ModulePass(ID) {}

		bool runOnModule(Module &M) override;

	private:
		bool processFunction(Function &F);
		bool cloneFunctionWithConstants(CallInst *callInst, Function *targetFunction);
	};

	char FuncParamProcessorPass::ID = 0;
	static RegisterPass<FuncParamProcessorPass> X("hello", "Function Parameter Processing Pass", false, false);

	bool FuncParamProcessorPass::runOnModule(Module &M)
	{
		bool modified = false;
		for (Function &F : M)
		{
			if (!F.isDeclaration())
			{
				modified |= processFunction(F);
			}
		}
		return modified;
	}

	bool FuncParamProcessorPass::processFunction(Function &F)
	{
