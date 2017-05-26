#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1

# Run GT.M process started with %XCMD in background.
($gtm_exe/mumps -run %XCMD 'set ^proc1=$j set ^a=1' &)


# Run MUMPS program in background.
cat >& mprg2.m <<EOF
mprg2;
	set ^proc2=\$j
	set ^b=1
	quit
EOF
($gtm_exe/mumps -run mprg2 &)

cat >& script.csh <<EOF
\$GTM <<EOFGTM
	set ^proc3=\\\$j
	quit
EOFGTM
EOF

(source script.csh &)

# Following two loops ensure that both the backgrounded processes have finished execution.
$gtm_exe/mumps -r %XCMD 'for i=1:1 quit:$get(^proc1)'
$gtm_exe/mumps -r %XCMD 'for i=1:1 quit:$get(^proc2)'
$gtm_exe/mumps -r %XCMD 'for i=1:1 quit:$get(^proc3)'
@ p1 = `$gtm_exe/mumps -run %XCMD 'write ^proc1'`
@ p2 = `$gtm_exe/mumps -run %XCMD 'write ^proc2'`
@ p3 = `$gtm_exe/mumps -run %XCMD 'write ^proc3'`

# Backgrounded GT.M processes are stuck if they do not finish execution after 120 seconds.
$gtm_tst/com/wait_for_proc_to_die.csh $p1 120
$gtm_tst/com/wait_for_proc_to_die.csh $p2 120
$gtm_tst/com/wait_for_proc_to_die.csh $p3 120
$gtm_tst/com/dbcheck.csh
