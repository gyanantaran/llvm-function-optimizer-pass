#define DEBUG_TYPE "helloarguments"
#include "llvm/Pass.h"
#include "llvm/IR/Function.h"
#include "llvm/Support/raw_ostream.h"

using namespace llvm;



namespace {
	struct HelloArguments :  public FunctionPass
	{

		/** Constructor. */
		static char ID;                           
		HelloArguments() : FunctionPass(ID) {}

		//DEFINE_INTPASS_ANALYSIS_ADJUSTMENT(PointerAnalysisPass);

		/**
		 * @brief Runs this pass on the given function.
		 * @param [in,out] func The function to analyze
		 * @return true if the function was modified; false otherwise
		 */
		virtual bool runOnFunction(llvm::Function &F){
			errs() << "HelloArguments: " ;
			errs().write_escaped(F.getName())<< "\n";

			for (auto Arg = F.arg_begin(); Arg != F.arg_end(); ++Arg) {
				errs() << "  Parameter: ";
				errs().write_escaped(Arg->getName()) << "\n";
			}
			return false;
		}

	};
}

char HelloArguments::ID = 0;
static RegisterPass<HelloArguments> X("helloarguments", "HelloArguments World Pass", false, false);



