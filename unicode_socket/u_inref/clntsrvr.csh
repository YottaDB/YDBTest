#! /usr/local/bin/tcsh -f
#  clntsrvr.csh
#  	-- client server test
$switch_chset UTF-8 
echo ENTERING SOCKET CLNTSRVR
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << EOF
s ^configasalongvariablename78901("hostname")="$tst_org_host"
s ^configasalongvariablename78901("delim")=\$C(13)
s ^configasalongvariablename78901("portno")=$portno
h
EOF
$GTM << EOF
d ^socclntsrvr(1)
h
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET CLNTSRVR
