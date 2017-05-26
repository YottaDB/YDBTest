; This script is used by GTM6813 subtest and tests various internal, external,
; DO, $$, and indirect invocations.
docalls
	set $ecode=""
        set $etrap="do etrap^docalls"
	
	; internal extrinsics

	do doline
	write "Calling internal extrinsic: $$foo -> foo",!,"    "
	do ^intExtrNoFmlLstCldNoPrn

	do doline
	write "Calling internal extrinsic: $$foo() -> foo",!,"    "
	do ^intExtrNoFmlLstCldPrn

	do doline
	write "Calling internal extrinsic: $$foo(1) -> foo",!,"    "
	do ^intExtrNoFmlLstCldPrm

	do doline
	write "Calling internal extrinsic: $$foo -> foo()",!,"    "
	do ^intExtrEmpFmlLstCldNoPrn

	do doline
	write "Calling internal extrinsic: $$foo() -> foo()",!,"    "
	do ^intExtrEmpFmlLstCldPrn

	do doline
	write "Calling internal extrinsic: $$foo(1) -> foo()",!,"    "
	do ^intExtrEmpFmlLstCldPrm

	do doline
	write "Calling internal extrinsic: $$foo -> foo(x,y)",!,"    "
	do ^intExtrWithFmlLstCldNoPrn

	do doline
	write "Calling internal extrinsic: $$foo() -> foo(x,y)",!,"    "
	do ^intExtrWithFmlLstCldPrn

	do doline
	write "Calling internal extrinsic: $$foo(1) -> foo(x,y)",!,"    "
	do ^intExtrWithFmlLstCldNoPrn

	; internal labels

	do doline
	write "Calling internal label: do foo -> foo",!,"    "
	do ^intLblNoFmlLstCldNoPrn

	do doline
	write "Calling internal label: do foo() -> foo",!,"    "
	do ^intLblNoFmlLstCldPrn

	do doline
	write "Calling internal label: do foo(1) -> foo",!,"    "
	do ^intLblNoFmlLstCldPrm

	do doline
	write "Calling internal label: do foo -> foo()",!,"    "
	do ^intLblEmpFmlLstCldNoPrn

	do doline
	write "Calling internal label: do foo() -> foo()",!,"    "
	do ^intLblEmpFmlLstCldPrn

	do doline
	write "Calling internal label: do foo(1) -> foo()",!,"    "
	do ^intLblEmpFmlLstCldPrm

	do doline
	write "Calling internal label: do foo -> foo(x,y)",!,"    "
	do ^intLblWithFmlLstCldNoPrn

	do doline
	write "Calling internal label: do foo() -> foo(x,y)",!,"    "
	do ^intLblWithFmlLstCldPrn

	do doline
	write "Calling internal label: do foo(1) -> foo(x,y)",!,"    "
	do ^intLblWithFmlLstCldNoPrn

	; indirect internal extrinsics

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo"" -> foo",!,"    "
	do ^intExtrNoFmlLstCldIndNoPrn

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo()"" -> foo",!,"    "
	do ^intExtrNoFmlLstCldIndPrn

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo(1)"" -> foo",!,"    "
	do ^intExtrNoFmlLstCldIndPrm

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo"" -> foo()",!,"    "
	do ^intExtrEmpFmlLstCldIndNoPrn

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo()"" -> foo()",!,"    "
	do ^intExtrEmpFmlLstCldIndPrn

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo(1)"" -> foo()",!,"    "
	do ^intExtrEmpFmlLstCldIndPrm

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo"" -> foo(x,y)",!,"    "
	do ^intExtrWithFmlLstCldIndNoPrn

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo()"" -> foo(x,y)",!,"    "
	do ^intExtrWithFmlLstCldIndPrn

	do doline
	write "Calling internal extrinsic indirectly: @""$$foo(1)"" -> foo(x,y)",!,"    "
	do ^intExtrWithFmlLstCldIndNoPrn

	; indirect internal labels

	do doline
	write "Calling internal label indirectly: @""do foo"" -> foo",!,"    "
	do ^intLblNoFmlLstCldIndNoPrn

	do doline
	write "Calling internal label indirectly: @""do foo()"" -> foo",!,"    "
	do ^intLblNoFmlLstCldIndPrn

	do doline
	write "Calling internal label indirectly: @""do foo(1)"" -> foo",!,"    "
	do ^intLblNoFmlLstCldIndPrm

	do doline
	write "Calling internal label indirectly: @""do foo"" -> foo()",!,"    "
	do ^intLblEmpFmlLstCldIndNoPrn

	do doline
	write "Calling internal label indirectly: @""do foo()"" -> foo()",!,"    "
	do ^intLblEmpFmlLstCldIndPrn

	do doline
	write "Calling internal label indirectly: @""do foo(1)"" -> foo()",!,"    "
	do ^intLblEmpFmlLstCldIndPrm

	do doline
	write "Calling internal label indirectly: @""do foo"" -> foo(x,y)",!,"    "
	do ^intLblWithFmlLstCldIndNoPrn

	do doline
	write "Calling internal label indirectly: @""do foo()"" -> foo(x,y)",!,"    "
	do ^intLblWithFmlLstCldIndPrn

	do doline
	write "Calling internal label indirectly: @""do foo(1)"" -> foo(x,y)",!,"    "
	do ^intLblWithFmlLstCldIndNoPrn

	set $etrap=""
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set incrtrapPOST="write ""FAIL: "",$$^error(savestat),!"

	; external extrinsics

	do doline
	write "Calling external extrinsic: $$foo^bar -> foo",!,"    "
	if $$extExtrNoFmlLst^extExtrNoFmlLst 

	do doline
	write "Calling external extrinsic: $$foo^bar() -> foo",!,"    "
	if $$extExtrNoFmlLst^extExtrNoFmlLst()

	do doline
	write "Calling external extrinsic: $$foo^bar(1) -> foo",!,"    "
	if $$extExtrNoFmlLst^extExtrNoFmlLst(1)

	do doline
	write "Calling external extrinsic: $$foo^bar -> foo()",!,"    "
	if $$extExtrEmpFmlLst^extExtrEmpFmlLst 

	do doline
	write "Calling external extrinsic: $$foo^bar() -> foo()",!,"    "
	if $$extExtrEmpFmlLst^extExtrEmpFmlLst()

	do doline
	write "Calling external extrinsic: $$foo^bar(1) -> foo()",!,"    "
	if $$extExtrEmpFmlLst^extExtrEmpFmlLst(1)

	do doline
	write "Calling external extrinsic: $$foo^bar -> foo(x,y)",!,"    "
	if $$extExtrWithFmlLst^extExtrWithFmlLst 

	do doline
	write "Calling external extrinsic: $$foo^bar() -> foo(x,y)",!,"    "
	if $$extExtrWithFmlLst^extExtrWithFmlLst()

	do doline
	write "Calling external extrinsic: $$foo^bar(1) -> foo(x,y)",!,"    "
	if $$extExtrWithFmlLst^extExtrWithFmlLst(1)

	; external extrinsics called without specifying the label

	do doline
	write "Calling external extrinsic by routine name: $$^bar -> foo",!,"    "
	if $$^extExtrNoFmlLst 

	do doline
	write "Calling external extrinsic by routine name: $$^bar() -> foo",!,"    "
	if $$^extExtrNoFmlLst()

	do doline
	write "Calling external extrinsic by routine name: $$^bar(1) -> foo",!,"    "
	if $$^extExtrNoFmlLst(1)

	do doline
	write "Calling external extrinsic by routine name: $$^bar -> foo()",!,"    "
	if $$^extExtrEmpFmlLst 

	do doline
	write "Calling external extrinsic by routine name: $$^bar() -> foo()",!,"    "
	if $$^extExtrEmpFmlLst()

	do doline
	write "Calling external extrinsic by routine name: $$^bar(1) -> foo()",!,"    "
	if $$^extExtrEmpFmlLst(1)

	do doline
	write "Calling external extrinsic by routine name: $$^bar -> foo(x,y)",!,"    "
	if $$^extExtrWithFmlLst 

	do doline
	write "Calling external extrinsic by routine name: $$^bar() -> foo(x,y)",!,"    "
	if $$^extExtrWithFmlLst()

	do doline
	write "Calling external extrinsic by routine name: $$^bar(1) -> foo(x,y)",!,"    "
	if $$^extExtrWithFmlLst(1)

	; external labels

	do doline
	write "Calling external label: do foo^bar -> foo",!,"    "
	do extLblNoFmlLst^extLblNoFmlLst

	do doline
	write "Calling external label: do foo^bar() -> foo",!,"    "
	do extLblNoFmlLst^extLblNoFmlLst()

	do doline
	write "Calling external label: do foo^bar(1) -> foo",!,"    "
	do extLblNoFmlLst^extLblNoFmlLst(1)

	do doline
	write "Calling external label: do foo^bar -> foo()",!,"    "
	do extLblEmpFmlLst^extLblEmpFmlLst

	do doline
	write "Calling external label: do foo^bar() -> foo()",!,"    "
	do extLblEmpFmlLst^extLblEmpFmlLst()

	do doline
	write "Calling external label: do foo^bar(1) -> foo()",!,"    "
	do extLblEmpFmlLst^extLblEmpFmlLst(1)

	do doline
	write "Calling external label: do foo^bar -> foo(x,y)",!,"    "
	do extLblWithFmlLst^extLblWithFmlLst

	do doline
	write "Calling external label: do foo^bar() -> foo(x,y)",!,"    "
	do extLblWithFmlLst^extLblWithFmlLst()

	do doline
	write "Calling external label: do foo^bar(1) -> foo(x,y)",!,"    "
	do extLblWithFmlLst^extLblWithFmlLst(1)

	; external labels called without specifying the label

	do doline
	write "Calling external label by routine name: do ^bar -> foo",!,"    "
	do ^extLblNoFmlLst

	do doline
	write "Calling external label by routine name: do ^bar() -> foo",!,"    "
	do ^extLblNoFmlLst()

	do doline
	write "Calling external label by routine name: do ^bar(1) -> foo",!,"    "
	do ^extLblNoFmlLst(1)

	do doline
	write "Calling external label by routine name: do ^bar -> foo()",!,"    "
	do ^extLblEmpFmlLst

	do doline
	write "Calling external label by routine name: do ^bar() -> foo()",!,"    "
	do ^extLblEmpFmlLst()

	do doline
	write "Calling external label by routine name: do ^bar(1) -> foo()",!,"    "
	do ^extLblEmpFmlLst(1)

	do doline
	write "Calling external label by routine name: do ^bar -> foo(x,y)",!,"    "
	do ^extLblWithFmlLst

	do doline
	write "Calling external label by routine name: do ^bar() -> foo(x,y)",!,"    "
	do ^extLblWithFmlLst()

	do doline
	write "Calling external label by routine name: do ^bar(1) -> foo(x,y)",!,"    "
	do ^extLblWithFmlLst(1)

	; indirect external extrinsics

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar"" -> foo""",!,"    "
	if @"$$extExtrNoFmlLst^extExtrNoFmlLst" 

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar()"" -> foo""",!,"    "
	if @"$$extExtrNoFmlLst^extExtrNoFmlLst()"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar(1)"" -> foo""",!,"    "
	if @"$$extExtrNoFmlLst^extExtrNoFmlLst(1)"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar"" -> foo()""",!,"    "
	if @"$$extExtrEmpFmlLst^extExtrEmpFmlLst"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar()"" -> foo()""",!,"    "
	if @"$$extExtrEmpFmlLst^extExtrEmpFmlLst()"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar(1)"" -> foo()""",!,"    "
	if @"$$extExtrEmpFmlLst^extExtrEmpFmlLst(1)"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar"" -> foo(x,y)""",!,"    "
	if @"$$extExtrWithFmlLst^extExtrWithFmlLst"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar()"" -> foo(x,y)""",!,"    "
	if @"$$extExtrWithFmlLst^extExtrWithFmlLst()"

	do doline
	write "Calling external extrinsic indirectly: @""$$foo^bar(1)"" -> foo(x,y)""",!,"    "
	if @"$$extExtrWithFmlLst^extExtrWithFmlLst(1)"

	; indirect external extrinsics called without specifying the label

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar"" -> foo""",!,"    "
	if @"$$^extExtrNoFmlLst" 

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar()"" -> foo""",!,"    "
	if @"$$^extExtrNoFmlLst()"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar(1)"" -> foo""",!,"    "
	if @"$$^extExtrNoFmlLst(1)"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar"" -> foo()""",!,"    "
	if @"$$^extExtrEmpFmlLst"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar()"" -> foo()""",!,"    "
	if @"$$^extExtrEmpFmlLst()"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar(1)"" -> foo()""",!,"    "
	if @"$$^extExtrEmpFmlLst(1)"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar"" -> foo(x,y)""",!,"    "
	if @"$$^extExtrWithFmlLst"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar()"" -> foo(x,y)""",!,"    "
	if @"$$^extExtrWithFmlLst()"

	do doline
	write "Calling external extrinsic indirectly by routine name: @""$$^bar(1)"" -> foo(x,y)""",!,"    "
	if @"$$^extExtrWithFmlLst(1)"

	; indirect external labels

	do doline
	write "Calling external label indirectly: do @""foo^bar"" -> foo",!,"    "
	do @"extLblNoFmlLst^extLblNoFmlLst"

	do doline
	write "Calling external label indirectly: do @""foo^bar()"" -> foo",!,"    "
	do @"extLblNoFmlLst^extLblNoFmlLst()"

	do doline
	write "Calling external label indirectly: do @""foo^bar(1)"" -> foo",!,"    "
	do @"extLblNoFmlLst^extLblNoFmlLst(1)"

	do doline
	write "Calling external label indirectly: do @""foo^bar"" -> foo()",!,"    "
	do @"extLblEmpFmlLst^extLblEmpFmlLst"

	do doline
	write "Calling external label indirectly: do @""foo^bar()"" -> foo()",!,"    "
	do @"extLblEmpFmlLst^extLblEmpFmlLst()"

	do doline
	write "Calling external label indirectly: do @""foo^bar(1)"" -> foo()",!,"    "
	do @"extLblEmpFmlLst^extLblEmpFmlLst(1)"

	do doline
	write "Calling external label indirectly: do @""foo^bar"" -> foo(x,y)",!,"    "
	do @"extLblWithFmlLst^extLblWithFmlLst"

	do doline
	write "Calling external label indirectly: do @""foo^bar()"" -> foo(x,y)",!,"    "
	do @"extLblWithFmlLst^extLblWithFmlLst()"

	do doline
	write "Calling external label indirectly: do @""foo^bar(1)"" -> foo(x,y)",!,"    "
	do @"extLblWithFmlLst^extLblWithFmlLst(1)"

	; indirect external labels without specifying the label

	do doline
	write "Calling external label indirectly by routine name: do @""^bar"" -> foo",!,"    "
	do @"^extLblNoFmlLst"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar()"" -> foo",!,"    "
	do @"^extLblNoFmlLst()"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar(1)"" -> foo",!,"    "
	do @"^extLblNoFmlLst(1)"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar"" -> foo()",!,"    "
	do @"^extLblEmpFmlLst"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar()"" -> foo()",!,"    "
	do @"^extLblEmpFmlLst()"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar(1)"" -> foo()",!,"    "
	do @"^extLblEmpFmlLst(1)"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar"" -> foo(x,y)",!,"    "
	do @"^extLblWithFmlLst"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar()"" -> foo(x,y)",!,"    "
	do @"^extLblWithFmlLst()"

	do doline
	write "Calling external label indirectly by routine name: do @""^bar(1)"" -> foo(x,y)",!,"    "
	do @"^extLblWithFmlLst(1)"

	quit

doline
	write !,"---------------------------------------------------------------------------------------------------",!,!
	quit

etrap
	write "FAIL: ",$$error^error($zstatus),!
	set $ecode=""
	quit
