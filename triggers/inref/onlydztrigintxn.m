	; these tests exposed a bug in t_begin.c which expected gv_target to not be NULL.
	; op_fnztrigger restores gv_target, gv_curr_key and region/segment info to avoid
	; affecting ^() and $reference.  When the only operations in the transaction were
	; on ^#t, aka trigger operations, then gv_target is never set to anything other
	; than NULL. Because blocks are deleted, t_begin is called expecting the
	; gv_target->clue to be set in order to read the TN number to use as the base TN
	; of the transation
onlydztrigintxn
	do nogvdeleteall^onlydztrigintxn
	do nogvdeletebyname^onlydztrigintxn
	quit

	; ----------------------------------------------
	; exercise trigger_delete_all
nogvdeleteall
	do ^echoline
	write "Load a dummy trigger outside a transaction",!
	set x=$ztrigger("ITEM","+^antp(fillid=:) -commands=SET  -xecute=""hang 0.1 set ^cntp(fillid)=$ztval""")
	tstart ():serial
	write "Delete all triggers inside a transaction",!
	set x=$ztrigger("ITEM","-*")
	tcommit
	do ^echoline
	quit

	; ----------------------------------------------
	; exercise trigger_delete_name
nogvdeletebyname
	do ^echoline
	write "Load a dummy triggers outside a transaction. One is a multi-line trigger that exceeds a block",!
	set gtmtst=$ztrnlnm("gtm_tst")
	; input and output files
	set file="nogvdeletebyname.trg",msource=gtmtst_"/manual_tests/inref/smoketest.m"
	open msource:readonly
	open file:newversion
	use file
	; start writing the trigger(s)
	write "+^smoke -command=ZTR -name=deleteme -xecute=<<",!
	use msource
	for  read line quit:$zeof  do
	.	use file
	.	if $increment(bytes,$length(line)+1)>1048576  do
	.	.	write ">>",!
	.	.	write "+^smoke -command=ZTR -xecute=<<",!
	.	.	kill bytes
	.	write line,!
	.	use msource
	close msource
	use file write ">>",!
	close file
	; load the triggers and delete all inside a transation
	write "Delete all triggers by name inside a transaction",!
	do file^dollarztrigger("nogvdeletebyname.trg",1)
	tstart ():serial
	set x=$ztrigger("ITEM","-deleteme*")
	tcommit
	do ^echoline
	quit

