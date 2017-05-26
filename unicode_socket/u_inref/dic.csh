#! /usr/local/bin/tcsh -f
#
#
$switch_chset UTF-8 
echo ENTERING SOCKET DIC
#
#
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 1 128 256 1024
# --- configures the test ---
source $gtm_tst/com/portno_acquire.csh  >>& portno.out
$GTM << EOF
s ^configasalongvariablename78901("hostname")="$tst_org_host"
s ^configasalongvariablename78901("delim")=\$C(512)
s ^configasalongvariablename78901("portno")=$portno
h
EOF
($gtm_tst/$tst/u_inref/client2.csh >&! client2.out &) >&! client_background.log
$gtm_tst/$tst/u_inref/server2.csh >&! server2.out
# give time for the client2 to read last message
$GTM << EOF
d ^waitforread("last",30)
h
EOF
# --- stops the client2 process ---
$GTM << EOF
s ^stopasalongvariablename45678901="Y",^stopasalongvariable="N"
h
EOF
# give time for the client2 to pick up the signal
$GTM << EOF
d ^waitforread("all",20)
h
EOF
$gtm_tst/com/dbcheck.csh -extract mumps
cat client2.out
cat server2.out
#
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET DIC
