#! /usr/local/bin/tcsh -f
echo ENTERING C9G04002779 Socket and Mupip interrupt test
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << EOF
s ^config("hostname")="$tst_org_host"
s ^config("delim")=\$C(13)
s ^config("portno")=$portno
h
EOF

$gtm_dist/mumps -run tsockzintr >&! tsockzintr.out
$grep -vE '^$' tsockzintr.out

# look in done.log if any errors
$gtm_dist/mumps -run ^%XCMD 'zwrite ^done' >&! done.log

sleep 5
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING C9G04002779 Socket and Mupip interrupt test
