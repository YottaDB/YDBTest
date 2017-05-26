indlcl ;
	write "Long Name test for Max indirection",!
	set variableasalongname012345671="indtest"
	set unix=$zversion'["VMS"
	if unix set max=1000
	else  set max=230 ;VMS test needs to increase the user stack size setting in GTM$DEFAULTS.m64
	for cnt=1:1:max-1  do
	. set @("variableasalongname01234567"_(cnt+1))="@variableasalongname01234567"_cnt
	set variable="variableasalongname01234567"_max
	set @@variable="PASSED"
	zwrite indtest

V3NST2	;a small portion of code from mvts/inref/V3NST2.m
	set ALongVariableForMultiLevelIndir="ALongVariableForMultiLevelIndir"
	set ALongVariableForMulti="ALongVariableForMulti"
	set VCOMP=""
	set VCOMP=VCOMP_@@@@@ALongVariableForMultiLevelIndir_@@@@@@@@@@@@@@@@@@@@ALongVariableForMultiLevelIndir_@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ALongVariableForMultiLevelIndir
	set VCORR="ALongVariableForMultiLevelIndirALongVariableForMultiLevelIndirALongVariableForMultiLevelIndir"
	do ^examine(VCOMP,VCORR,"in multi level indirection")
	quit

