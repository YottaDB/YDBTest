D000201	; D9605-000201 test code
	;
	; Test various arguments to the modulo operator
	;
	New (act)
	If '$Data(act)  New act  Set act="Write !,""D9605-000201 FAILED *** "",value,""#"",modulus,"" computed: "",oper,"" '= expected: "",expect"
	Set cnt=0
	;
	; These are the values reported in the support request.
	;
	Do D000201a(5,1E5,5)
	Do D000201a(5,1E6,5)
	Do D000201a(5,1E7,5)
	;
	;
	; These values are from pages 123  & 124 of _The_Complete_MUMPS_ by John Lewkowicz
	;
	Do D000201a(7,4,3)
	Do D000201a(7,-4,-1)
	Do D000201a(10,2,0)
	Do D000201a(3,2,1)
	Do D000201a(2,2,0)
	;
	;
	; Here a bunch more values to test boundary conditions.
	Do D000201a(0,10,0)
	Do D000201a(1,10,1)
	Do D000201a(1,1E5,1)
	Do D000201a(1,1E6,1)
	Do D000201a(10,5,0)
	Do D000201a(1E5,5,0)
	Do D000201a(1E6,5,0)
	;
	Do D000201a(0,10,0)
	Do D000201a(-1,10,9)
	Do D000201a(-1,1E5,99999)
	Do D000201a(-1,1E6,999999)
	Do D000201a(-10,5,0)
	Do D000201a(-1E5,5,0)
	Do D000201a(-1E6,5,0)
	;
	Do D000201a(0,-10,0)
	Do D000201a(1,-10,-9)
	Do D000201a(1,-1E5,-99999)
	Do D000201a(1,-1E6,-999999)
	Do D000201a(10,-5,0)
	Do D000201a(1E5,-5,0)
	Do D000201a(1E6,-5,0)
	;
	Do D000201a(0,-10,0)
	Do D000201a(-1,-10,-1)
	Do D000201a(-1,-1E5,-1)
	Do D000201a(-1,-1E6,-1)
	Do D000201a(-10,-5,0)
	Do D000201a(-1E5,-5,0)
	Do D000201a(-1E6,-5,0)
	;
	;
	Write !,$Select(cnt:"FAIL",1:"PASS")," from ",$Text(+0)
	Quit

D000201a(value,modulus,expect)
	;
	; First, use the operator.
	Set oper=value#modulus
	;
	; Then, perform the explicit computation.
	Set iquo=value\modulus
	Set fquo=value/modulus
	If (iquo'=fquo)&(fquo<0)  Set iquo=iquo-1	; floor function
	Set calc=value-(iquo*modulus)
	;
	; Now, compare.
	If (oper'=calc)!(oper'=expect)!(oper*modulus<0)  Set cnt=cnt+1  Xecute act
	Quit
