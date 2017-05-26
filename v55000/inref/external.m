; This script is used by GTM6813 subtests and is supplementary to the gtm_zquit_anyway and undefined variable testing.
external
	quit

extExtrNoQuitArg()
	write "External extrinsic that has no quit argument",!
	quit

extLabelWithQuitArg()
	write "External label that returns a value",!
	quit 1

extLabelWithQuitExpr()
	write "External label that has an evaluated quit expression",!
	quit $$extExtrEvalExpr()

extExtrEvalExpr()
	write "External extrinsic that gets evaluated",!
	quit 1

extExtrEmpFmlLstEvalX()
	write "X is "_x_": PASSED",!
	quit 1

extExtrOneArgNotXEvalX(y)
	write "X is "_x_": PASSED",!
	quit 1

extExtrOneArgIsXEvalX(x)
	write "X is "_x_": PASSED",!
	quit 1

extExtrFewArgsNotXEvalX(y,z)
	write "X is "_x_": PASSED",!
	quit 1
	
extExtrFewArgsWithXEvalX(y,x)
	write "X is "_x_": PASSED",!
	quit 1

extLblNoFmlLstEvalX
	write "X is "_x_": PASSED",!
	quit

extLblEmpFmlLstEvalX()
	write "X is "_x_": PASSED",!
	quit

extLblOneArgNotXEvalX(y)
	write "X is "_x_": PASSED",!
	quit

extLblOneArgIsXEvalX(x)
	write "X is "_x_": PASSED",!
	quit

extLblFewArgsNotXEvalX(y,z)
	write "X is "_x_": PASSED",!
	quit
	
extLblFewArgsWithXEvalX(y,x)
	write "X is "_x_": PASSED",!
	quit
