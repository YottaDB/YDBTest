#!/usr/local/bin/tcsh -f
#trigmupipload
#
#trigmupipload, verfiy that no triggers are fired on primary or secondary when doing mupip load
#

$gtm_tst/com/dbcreate.csh mumps 1

cat > trigzmupipload.trg << TFILE
+^a(subs=:) -command=S -xecute="set ^b(subs)=\$ZTVALUE write \$ztrig,\$c(9),\$reference,"" = "",\$ZTVALUE,!"
TFILE

cat > trigmupipload.m << MPROG
trigmupipload
	write "Updates to ^a() trigger the following changes to ^b()",!
	; modify ^a to fire the triggers for all ^a() globals
	for i=1:1:10 set ^a(i)=i
	quit
MPROG

$load trigzmupipload.trg "" -noprompt
$show

$echoline
echo "output from trigmupipload M routine"
$echoline
echo ""

$gtm_exe/mumps -run trigmupipload

echo ""
$echoline
echo ""

$gtm_exe/mumps -dir <<DOKILLB
kill ^b
zwrite ^b
DOKILLB

$gtm_exe/mupip extract trig_pri.ext

$gtm_exe/mumps -dir <<DOKILLA
kill ^a
zwrite ^a
DOKILLA

$gtm_exe/mupip load trig_pri.ext

$gtm_exe/mumps -dir <<AFTERLOAD
zwrite ^a,^b
AFTERLOAD

# only do the following if replication is turned on
if ($?test_replic == 1) then
	set stat = `$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_transaction_seqno.csh 22 RCVR 60;echo $status"`

	if (0 != "$stat") then
		echo "TEST-E-TRANSACTIONS processed by the secondary did not reach the expected number (22)"
		echo "Since the rest of the test relies on this, no point in continuing it. Will exit now."
		$gtm_tst/com/dbcheck.csh
		exit 1
	endif
endif

$gtm_tst/com/dbcheck.csh -extract
