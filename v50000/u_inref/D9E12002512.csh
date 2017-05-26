#!/usr/local/bin/tcsh
#
# D9E12-002512 DSE ADD -STAR gets SIGADRALN error
#
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
$gtm_tst/com/dbcreate.csh mumps 1 -block=512 -rec=480
$GTM << EOF
	d ^d002512
EOF
cp mumps.dat mumpsbak.dat
$DSE << DSE_EOF >>&! dse_addstr.log
	dump -block=4
	remove -rec=7
	add -star -pointer=3
	dump -block=4
	remove -rec=7
	remove -rec=6
	add -star -pointer=A
	dump -block=4
	remove -rec=6
	remove -rec=5
	add -star -pointer=9
	dump -block=4
	remove -rec=5
	remove -rec=4
	add -star -pointer=8
	dump -block=4
	remove -rec=4
	remove -rec=3
	add -star -pointer=7
	dump -block=4
	remove -rec=3
	remove -rec=2
	add -star -pointer=6
	dump -block=4
	remove -rec=2
	remove -rec=1
	add -star -pointer=5
	dump -block=4
	exit
DSE_EOF
$grep -v '|' dse_addstr.log
if ($HOSTOS == "OSF1") then
	echo ""
endif	
echo "End of test"
$gtm_tst/com/dbcheck.csh
