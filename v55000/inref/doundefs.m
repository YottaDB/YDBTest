doundefs
	set $ecode=""
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1
	set incrtrapPOST="write ""FAIL: ""  write $$^error(savestat),!"

	do doline
	if $$intExtrEmpFmlLstEvalX()
	
	do doline
	if $$intExtrOneArgNotXEvalX(1)
	
	do doline
	if $$intExtrOneArgNotXEvalX(x)
	
	do doline
	if $$intExtrOneArgIsXEvalX()
	
	do doline
	if $$intExtrOneArgIsXEvalX(y)
	
	do doline
	if $$intExtrFewArgsNotXEvalX(0,1)
	
	do doline
	if $$intExtrFewArgsNotXEvalX(x,1)

	do doline
	if $$intExtrFewArgsWithXEvalX()
	
	do doline
	if $$intExtrFewArgsWithXEvalX(x,1)
	
	do doline
	if $$intExtrFewArgsWithXEvalX(1)
	
	set x=0

	do doline
	if $$intExtrEmpFmlLstEvalX()
	
	do doline
	if $$intExtrOneArgNotXEvalX(1)
	
	do doline
	if $$intExtrOneArgNotXEvalX(x)
	
	do doline
	if $$intExtrOneArgIsXEvalX()
	
	do doline
	if $$intExtrOneArgIsXEvalX(y)
	
	do doline
	if $$intExtrFewArgsNotXEvalX(0,1)
	
	do doline
	if $$intExtrFewArgsNotXEvalX(x,1)

	do doline
	if $$intExtrFewArgsWithXEvalX()
	
	do doline
	if $$intExtrFewArgsWithXEvalX(x,1)
	
	do doline
	if $$intExtrFewArgsWithXEvalX(1)
	
	zkill x
	do doline

	;---------------------------------------------------------------

	do doline
	do intLblNoFmlLstEvalX

	do doline
	do intLblEmpFmlLstEvalX()
	
	do doline
	do intLblOneArgNotXEvalX(1)
	
	do doline
	do intLblOneArgNotXEvalX(x)
	
	do doline
	do intLblOneArgIsXEvalX()
	
	do doline
	do intLblOneArgIsXEvalX(y)
	
	do doline
	do intLblFewArgsNotXEvalX(0,1)
	
	do doline
	do intLblFewArgsNotXEvalX(x,1)

	do doline
	do intLblFewArgsWithXEvalX()
	
	do doline
	do intLblFewArgsWithXEvalX(x,1)
	
	do doline
	do intLblFewArgsWithXEvalX(1)
	
	set x=0

	do doline
	do intLblNoFmlLstEvalX

	do doline
	do intLblEmpFmlLstEvalX()
	
	do doline
	do intLblOneArgNotXEvalX(1)
	
	do doline
	do intLblOneArgNotXEvalX(x)
	
	do doline
	do intLblOneArgIsXEvalX()
	
	do doline
	do intLblOneArgIsXEvalX(y)
	
	do doline
	do intLblFewArgsNotXEvalX(0,1)
	
	do doline
	do intLblFewArgsNotXEvalX(x,1)

	do doline
	do intLblFewArgsWithXEvalX()
	
	do doline
	do intLblFewArgsWithXEvalX(x,1)

	do doline
	do intLblFewArgsWithXEvalX(1)

	zkill x
	do doline

	;---------------------------------------------------------------

	do doline
	if $$extExtrEmpFmlLstEvalX^external()
	
	do doline
	if $$extExtrOneArgNotXEvalX^external(1)
	
	do doline
	if $$extExtrOneArgNotXEvalX^external(x)
	
	do doline
	if $$extExtrOneArgIsXEvalX^external()
	
	do doline
	if $$extExtrOneArgIsXEvalX^external(y)
	
	do doline
	if $$extExtrFewArgsNotXEvalX^external(0,1)
	
	do doline
	if $$extExtrFewArgsNotXEvalX^external(x,1)

	do doline
	if $$extExtrFewArgsWithXEvalX^external()
	
	do doline
	if $$extExtrFewArgsWithXEvalX^external(x,1)
	
	do doline
	if $$extExtrFewArgsWithXEvalX^external(1)
	
	set x=0

	do doline
	if $$extExtrEmpFmlLstEvalX^external()
	
	do doline
	if $$extExtrOneArgNotXEvalX^external(1)
	
	do doline
	if $$extExtrOneArgNotXEvalX^external(x)
	
	do doline
	if $$extExtrOneArgIsXEvalX^external()
	
	do doline
	if $$extExtrOneArgIsXEvalX^external(y)
	
	do doline
	if $$extExtrFewArgsNotXEvalX^external(0,1)
	
	do doline
	if $$extExtrFewArgsNotXEvalX^external(x,1)

	do doline
	if $$extExtrFewArgsWithXEvalX^external()
	
	do doline
	if $$extExtrFewArgsWithXEvalX^external(x,1)
	
	do doline
	if $$extExtrFewArgsWithXEvalX^external(1)
	
	zkill x
	do doline

	;---------------------------------------------------------------

	do doline
	do extLblNoFmlLstEvalX^external

	do doline
	do extLblEmpFmlLstEvalX^external()
	
	do doline
	do extLblOneArgNotXEvalX^external(1)
	
	do doline
	do extLblOneArgNotXEvalX^external(x)
	
	do doline
	do extLblOneArgIsXEvalX^external()
	
	do doline
	do extLblOneArgIsXEvalX^external(y)
	
	do doline
	do extLblFewArgsNotXEvalX^external(0,1)
	
	do doline
	do extLblFewArgsNotXEvalX^external(x,1)

	do doline
	do extLblFewArgsWithXEvalX^external()
	
	do doline
	do extLblFewArgsWithXEvalX^external(x,1)
	
	do doline
	do extLblFewArgsWithXEvalX^external(1)
	
	set x=0

	do doline
	do extLblNoFmlLstEvalX^external

	do doline
	do extLblEmpFmlLstEvalX^external()
	
	do doline
	do extLblOneArgNotXEvalX^external(1)
	
	do doline
	do extLblOneArgNotXEvalX^external(x)
	
	do doline
	do extLblOneArgIsXEvalX^external()
	
	do doline
	do extLblOneArgIsXEvalX^external(y)
	
	do doline
	do extLblFewArgsNotXEvalX^external(0,1)
	
	do doline
	do extLblFewArgsNotXEvalX^external(x,1)

	do doline
	do extLblFewArgsWithXEvalX^external()
	
	do doline
	do extLblFewArgsWithXEvalX^external(x,1)

	do doline
	do extLblFewArgsWithXEvalX^external(1)

	quit

intExtrEmpFmlLstEvalX()
	write "X is "_x_": PASSED",!
	quit 1

intExtrOneArgNotXEvalX(y)
	write "X is "_x_": PASSED",!
	quit 1

intExtrOneArgIsXEvalX(x)
	write "X is "_x_": PASSED",!
	quit 1

intExtrFewArgsNotXEvalX(y,z)
	write "X is "_x_": PASSED",!
	quit 1
	
intExtrFewArgsWithXEvalX(y,x)
	write "X is "_x_": PASSED",!
	quit 1

intLblNoFmlLstEvalX
	write "X is "_x_": PASSED",!
	quit

intLblEmpFmlLstEvalX()
	write "X is "_x_": PASSED",!
	quit

intLblOneArgNotXEvalX(y)
	write "X is "_x_": PASSED",!
	quit

intLblOneArgIsXEvalX(x)
	write "X is "_x_": PASSED",!
	quit

intLblFewArgsNotXEvalX(y,z)
	write "X is "_x_": PASSED",!
	quit
	
intLblFewArgsWithXEvalX(y,x)
	write "X is "_x_": PASSED",!
	quit

doline
	write "---------------------------------------------------------------------------------------------------",!
	quit
