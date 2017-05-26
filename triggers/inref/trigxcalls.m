trigxcalls
	do ^echoline
	do text^dollarztrigger("trigxcallstfile^trigxcalls","trigxcalls.trg")
	do file^dollarztrigger("trigxcalls.trg",1)
	ztrigger ^trigmath
	do ^echoline
	quit

trigxcallstfile
	;+^trigmath -commands=ZTR -xecute="Write ""Do ^mathtst"",!  Do ^mathtst"
