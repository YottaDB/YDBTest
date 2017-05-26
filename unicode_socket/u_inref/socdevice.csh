#! /usr/local/bin/tcsh -f
$switch_chset UTF-8 
echo ENTERING SOCKET SOCDEVICE
setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps 1 125 500
\cp $gtm_tst/$tst/inref/socdev.zwr .
source $gtm_tst/com/portno_acquire.csh >>& portno.out
$GTM << setupconfiguration
s ^config("hostname")="$tst_org_host"
s ^config("portno")=$portno
for i=1:1:50 s ^delim(i)=\$C(13)
h
setupconfiguration
#
#
$MUPIP load socdev.zwr
if $status then
	echo $MUPIP load socdev.zwr failed
	exit 1
endif
#
#
mkdir save ; cp *.dat save
$GTM << GTM_EOF
d ^socdev("")
h
GTM_EOF
#
mkdir save_def ; cp *.dat save_def ; cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socdev("UTF-8")
h
GTM_EOF
#
mkdir save_UTF-8 ; cp *.dat save_UTF-8 ; cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socdev("UTF-16LE")
h
GTM_EOF
#
mkdir save_UTF-16LE ; cp *.dat save_UTF-16LE ; cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socdev("UTF-16BE")
h
GTM_EOF
#
mkdir save_UTF-16BE ; cp *.dat save_UTF-16BE ; cp -f save/* .
$GTM << GTM_EOF
s ^config("portno")=$portno
d ^socdev("UTF-16")
h
GTM_EOF
#
#
#
sleep 10
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING SOCKET SOCDEVICE
