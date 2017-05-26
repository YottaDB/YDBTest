#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1

cat >> badcomp.m << EOF
badcomp	;
	w "hello"!
	quit
EOF
echo "# Start background job with compile error"
$GTM << GTM_EOF >&! badcomp.outx &
	set ^A=0
	zcompile "badcomp.m"
	; Wait until lsof finishes
	for i=1:1:300 quit:1=^A  hang 1
	quit
GTM_EOF
set pid = $!
echo "# Wait until object file is created"
$gtm_tst/com/wait_for_log.csh -log badcomp.o
echo "# Output from lsof means badcomp.o is open (and probably locked).  We expect no output."
($lsof $tst_working_dir/badcomp.o > lsof.outx) >& lsof.err
cat lsof.outx
echo "# Signal background zcompile job to finish"
$GTM << GTM_EOF
	set ^A=1
	quit
GTM_EOF
$gtm_tst/com/wait_for_proc_to_die.csh $pid
$gtm_tst/com/dbcheck.csh
