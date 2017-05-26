#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 3
$GDE << EOF
	add -name ERRORS* -region=areg 
	add -name ERTEMP* -region=breg
	exit
EOF
# GTM-7541: $ORDER Reverse Operation Returns Incorrect Global
# In V60000, this would incorrectly print "^ERR" instead of "^ERRORSPTR"
$GTM << EOF
	set (^ERR,^ERRORS,^ERRORSPTR,^ERTEMPP0)=1
	write \$order(^ERTEMP,-1),!
EOF
# GTM-7544: $ORDER Signal 11 when Environment Specification is Used
# In V60000, this would SIG-11.
$GTM << EOF
	write \$order(^["mumps.gld"]ERTEMP,-1)
EOF
$gtm_tst/com/dbcheck.csh
