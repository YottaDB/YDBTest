var;
	w "===========================================",!
	w "string:",!
	w ^["/this/sample","lespaul"]GBL,!
	s var="lespaul"
	s vara="/this/sample"
	w "variables:",!
	w ^[vara,var]GBL,!
	w "vara:",vara,";var:",var,!
	s ind="var"
	s indi="vara"
	w "indirection:",!
	w ^[@indi,@ind]GBL,!
	s str="zzz lespaul zzz"
	s str1="zzz /this/sample zzz"
	w "functions:",!
	w ^[$P(str1," ",2),$P(str," ",2)]GBL,!
	w "===========================================",!
	q

