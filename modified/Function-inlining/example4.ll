; ModuleID = '../output/optz_bc/Function-inlining/example4.hello.bc'
target datalayout = "e-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-v64:64:64-v128:128:128-a0:0:64-s0:64:64-f80:128:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

@.str = private unnamed_addr constant [5 x i8] c"%d \0A\00", align 1

; Function Attrs: nounwind uwtable
define i32 @pow2(i32 %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  %y = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  %0 = load i32* %x.addr, align 4
  %1 = load i32* %x.addr, align 4
  %mul = mul nsw i32 %0, %1
  store i32 %mul, i32* %y, align 4
  %2 = load i32* %y, align 4
  ret i32 %2
}

; Function Attrs: nounwind uwtable
define i32 @poly(i32 %y) #0 {
entry:
  %y.addr = alloca i32, align 4
  %p2 = alloca i32, align 4
  store i32 %y, i32* %y.addr, align 4
  %call = call i32 @pow2_cloned(i32 7)
  %0 = load i32* %y.addr, align 4
  %add = add nsw i32 %call, %0
  store i32 %add, i32* %p2, align 4
  %1 = load i32* %p2, align 4
  ret i32 %1
}

; Function Attrs: nounwind uwtable
define void @print_int(i32 %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, i32* %x.addr, align 4
  %0 = load i32* %x.addr, align 4
  %call = call i32 (i8*, ...)* @printf(i8* getelementptr inbounds ([5 x i8]* @.str, i32 0, i32 0), i32 %0)
  ret void
}

declare i32 @printf(i8*, ...) #1

; Function Attrs: nounwind uwtable
define i32 @main() #0 {
entry:
  %retval = alloca i32, align 4
  %p = alloca i32, align 4
  store i32 0, i32* %retval
  %call = call i32 @poly_cloned(i32 3)
  store i32 %call, i32* %p, align 4
  %0 = load i32* %p, align 4
  call void @print_int(i32 %0)
  ret i32 0
}

; Function Attrs: nounwind uwtable
define i32 @pow2_cloned(i32) #0 {
entry:
  %x.addr = alloca i32, align 4
  %y = alloca i32, align 4
  store i32 7, i32* %x.addr, align 4
  %1 = load i32* %x.addr, align 4
  %2 = load i32* %x.addr, align 4
  %mul = mul nsw i32 %1, %2
  store i32 %mul, i32* %y, align 4
  %3 = load i32* %y, align 4
  ret i32 %3
}

; Function Attrs: nounwind uwtable
define i32 @poly_cloned(i32) #0 {
entry:
  %y.addr = alloca i32, align 4
  %p2 = alloca i32, align 4
  store i32 3, i32* %y.addr, align 4
  %call = call i32 @pow2_cloned_cloned(i32 7)
  %1 = load i32* %y.addr, align 4
  %add = add nsw i32 %call, %1
  store i32 %add, i32* %p2, align 4
  %2 = load i32* %p2, align 4
  ret i32 %2
}

; Function Attrs: nounwind uwtable
define i32 @pow2_cloned_cloned(i32) #0 {
entry:
  %x.addr = alloca i32, align 4
  %y = alloca i32, align 4
  store i32 7, i32* %x.addr, align 4
  %1 = load i32* %x.addr, align 4
  %2 = load i32* %x.addr, align 4
  %mul = mul nsw i32 %1, %2
  store i32 %mul, i32* %y, align 4
  %3 = load i32* %y, align 4
  ret i32 %3
}

attributes #0 = { nounwind uwtable "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }

!llvm.ident = !{!0}

!0 = metadata !{metadata !"clang version 3.4.2 "}
