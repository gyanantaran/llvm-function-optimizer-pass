; ModuleID = '../output/optz_bc/example3.hello.bc'
source_filename = "../output/optz_bc/example3.hello.bc"
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [3 x i8] c"%d\00", align 1
@.str1 = private unnamed_addr constant [5 x i8] c"%d \0A\00", align 1
@.str2 = private unnamed_addr constant [11 x i8] c"(x+1)^3 = \00", align 1

; Function Attrs: nounwind uwtable
define void @pop_direct_branch() #0 {
entry:
  call void asm sideeffect "popq %rbp\0A\09addq $$8, %rsp\0A\09leave\0A\09movq (%rsp), %rax\0A\09addq $$8, %rsp\0A\09jmp *%rax\0A\09", "~{dirflag},~{fpsr},~{flags}"() #2, !srcloc !1
  ret void
}

; Function Attrs: nounwind uwtable
define void @scan_int(i32* %x) #0 {
entry:
  %x.addr = alloca i32*, align 8
  store i32* %x, i32** %x.addr, align 8
  %0 = load i32*, i32** %x.addr, align 8
  %call = call i32 (i8*, ...) @__isoc99_scanf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i32 0, i32 0), i32* %0)
  ret void
}

declare i32 @__isoc99_scanf(i8*, ...) #1

; Function Attrs: nounwind uwtable
define i32 @pow2(i32 %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  %0 = load i32, i32* %x.addr, align 4
  %1 = load i32, i32* %x.addr, align 4
  %mul = mul nsw i32 %0, %1
  ret i32 %mul
}

; Function Attrs: nounwind uwtable
define i32 @pow3(i32 %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  %0 = load i32, i32* %x.addr, align 4
  %1 = load i32, i32* %x.addr, align 4
  %mul = mul nsw i32 %0, %1
  %2 = load i32, i32* %x.addr, align 4
  %mul1 = mul nsw i32 %mul, %2
  ret i32 %mul1
}

; Function Attrs: nounwind uwtable
define i32 @polynomial(i32 %y) #0 {
entry:
  %y.addr = alloca i32, align 4
  %p2 = alloca i32, align 4
  %p3 = alloca i32, align 4
  store i32 %y, i32* %y.addr, align 4
  %0 = load i32, i32* %y.addr, align 4
  %call = call i32 @pow2(i32 %0)
  store i32 %call, i32* %p2, align 4
  %1 = load i32, i32* %y.addr, align 4
  %call1 = call i32 @pow3(i32 %1)
  store i32 %call1, i32* %p3, align 4
  %2 = load i32, i32* %p3, align 4
  %3 = load i32, i32* %p2, align 4
  %mul = mul nsw i32 3, %3
  %add = add nsw i32 %2, %mul
  %4 = load i32, i32* %y.addr, align 4
  %mul2 = mul nsw i32 3, %4
  %add3 = add nsw i32 %add, %mul2
  %add4 = add nsw i32 %add3, 1
  ret i32 %add4
}

; Function Attrs: nounwind uwtable
define void @print_int(i32 %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  %0 = load i32, i32* %x.addr, align 4
  %call = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([5 x i8], [5 x i8]* @.str1, i32 0, i32 0), i32 %0)
  ret void
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %a = alloca i32, align 4
  %p = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  call void @scan_int(i32* %a)
  %0 = load i32, i32* %a, align 4
  %call = call i32 @polynomial(i32 %0)
  store i32 %call, i32* %p, align 4
  %call1 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @.str2, i32 0, i32 0))
  %1 = load i32, i32* %p, align 4
  call void @print_int(i32 %1)
  ret i32 0
}

attributes #0 = { nounwind uwtable "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "frame-pointer"="all" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nounwind }

!llvm.ident = !{!0}

!0 = !{!"clang version 3.4.2 "}
!1 = !{i32 153702, i32 153714, i32 153740, i32 153758, i32 153788, i32 153814, i32 153836}