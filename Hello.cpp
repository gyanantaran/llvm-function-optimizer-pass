#include "llvm/Pass.h"
#include "llvm/IR/Module.h"
#include "llvm/IR/Function.h"
#include "llvm/IR/BasicBlock.h"
#include "llvm/IR/Instructions.h"
#include "llvm/IR/Constants.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/Transforms/Utils/Cloning.h"

using namespace llvm;

namespace {

	struct Hello : public ModulePass {
		static char ID;
		Hello() : ModulePass(ID) {}

		virtual bool runOnModule(Module &M) override {
			errs() << "Hello Pass: Analyzing Module - ";
			errs().write_escaped(M.getModuleIdentifier()) << "\n";

			Function *clonedFunction = nullptr;

			for (Function &F : M) {
				errs() << "Analyzing Function: ";
				errs().write_escaped(F.getName()) << "\n";
				errs() << "----------------" << "\n";

				for (BasicBlock &BB : F) {
					for (Instruction &I : BB) {
						if (auto *CI = dyn_cast<CallInst>(&I)) {
							if (auto *CalledFunc = CI->getCalledFunction()) {
								for (unsigned i = 0; i < CI->getNumArgOperands(); ++i) {
									Value *ArgValue = CI->getArgOperand(i);
									errs() << "Argument: ";
									errs().write_escaped(ArgValue->getName()) << "\n";

									if (auto *ConstantArg = dyn_cast<ConstantInt>(ArgValue)) {
										int ConstantValue = ConstantArg->getSExtValue();
										errs() << "**************** \n";
										errs() << "Constant Value: " << ConstantValue << "\n";

										unsigned NumConstants = 1;
										for (unsigned j = 1; j < CI->getNumArgOperands(); ++j) {
											if (isa<ConstantInt>(CI->getArgOperand(j))) {
												NumConstants++;
											} else {
												break;
											}
											// Removed errs() from the line below for clarity
											errs().write_escaped("Number of Consecutive Constants: ") << NumConstants << "\n";
										}

										if (NumConstants == 1) {
											std::string BaseName = CalledFunc->getName().str() + "_cloned";
											std::string ClonedName = BaseName;

											unsigned Counter = 1;
											while (M.getFunction(ClonedName)) {
												ClonedName = BaseName + "_" + std::to_string(Counter);
												Counter++;
											}

											Function *ClonedFunc = Function::Create(CalledFunc->getFunctionType(),
													CalledFunc->getLinkage(),
													ClonedName,
													&M);

											ValueToValueMapTy VMap;
											Function::arg_iterator DestI = ClonedFunc->arg_begin();

											for (Function::arg_iterator AI = CalledFunc->arg_begin(), AE = CalledFunc->arg_end(); AI != AE; ++AI) {
												VMap[&*AI] = &*DestI++;
											}

											SmallVector<ReturnInst *, 8> Returns;
											CloneFunctionInto(ClonedFunc, CalledFunc, VMap, /*ModuleLevelChanges=*/true, Returns);

											clonedFunction = ClonedFunc;

											errs() << "Cloning Function Call for Constant Argument\n";

											CI->setCalledFunction(clonedFunction);
											errs() << "Replaced Call to Function '" << CalledFunc->getName() << "' with '" << clonedFunction->getName() << "'\n";

											for (auto Arg = clonedFunction->arg_begin(); Arg != clonedFunction->arg_end(); ++Arg) {
												if (auto *ConstantArg = dyn_cast<ConstantInt>(CI->getArgOperand(Arg->getArgNo()))) {
													(*Arg).replaceAllUsesWith(ConstantArg);
													errs() << "Replaced Argument '" << Arg->getName() << "' with Constant Value: " << ConstantArg << "\n";
												}
											}

											errs() << "************** \n";
										} else {
											std::string BaseName = CalledFunc->getName().str() + "_cloned";
											std::string ClonedName = BaseName;

											unsigned Counter = 1;
											while (M.getFunction(ClonedName)) {
												ClonedName = BaseName + "_" + std::to_string(Counter);
												Counter++;
											}

											Function *ClonedFunc = Function::Create(CalledFunc->getFunctionType(),
													CalledFunc->getLinkage(),
													ClonedName,
													&M);

											ValueToValueMapTy VMap;
											Function::arg_iterator DestI = ClonedFunc->arg_begin();

											for (Function::arg_iterator AI = CalledFunc->arg_begin(), AE = CalledFunc->arg_end(); AI != AE; ++AI) {
												VMap[&*AI] = &*DestI++;
											}

											SmallVector<ReturnInst *, 8> Returns;
											CloneFunctionInto(ClonedFunc, CalledFunc, VMap, /*ModuleLevelChanges=*/true, Returns);

											clonedFunction = ClonedFunc;

											errs() << "Cloning Function Call for Multiple Constant Arguments\n";

											CI->setCalledFunction(clonedFunction);
											errs() << "Replaced Call to Function '" << CalledFunc->getName() << "' with '" << clonedFunction->getName() << "'\n";

											for (auto Arg = clonedFunction->arg_begin(); Arg != clonedFunction->arg_end(); ++Arg) {
												if (auto *ConstantArg = dyn_cast<ConstantInt>(CI->getArgOperand(Arg->getArgNo()))) {
													(*Arg).replaceAllUsesWith(ConstantArg);
													errs() << "Replaced Argument '" << Arg->getName() << "' with Constant Value: " << ConstantArg << "\n";
												}
											}

											errs() << "************** \n";
										}
									} else {
										errs() << "Skipping (Not a Constant)\n";
									}
								}
							}
						}
					}
				}
			}

			return false;
		}
	};

} // namespace

char Hello::ID = 0;
static RegisterPass<Hello> X("hello", "Function Constant Argument Optimizer", false, false);

