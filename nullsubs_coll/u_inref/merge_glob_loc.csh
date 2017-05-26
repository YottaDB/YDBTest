#!/usr/local/bin/tcsh -f
##############################################################################################
# check for all merge combinations between globals-globals, globals-locals & locals-globals
# with std. nullcoll & nostd. nullcoll qualifier on databases
##############################################################################################
cp $gtm_tst/$tst/inref/stdnull.gde .
$GDE << \gde_eof
@stdnull.gde
exit
\gde_eof
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
$GTM << \gtm_eof
do ^mergeop
halt
\gtm_eof
#
##############################################################################################
# check for all merge combinations between globals-globals, globals-locals
# with null_subscripts qualifier on databases
##############################################################################################
#
# we will have AREG-->ALLOW,BREG-->ALWAYS,CREG-->NEVER all used to test various combinations for global2
# DEFAULT region will be used for global1 which would be swtiched between various null_sub values
#
rm -f mumps.dat mumps.gld
cp $gtm_tst/$tst/inref/nullsub.gde .

$GDE << \gde_eof
@nullsub.gde
exit
\gde_eof
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create
$GTM << \gtm_eof
write "set globals with null_sub values",!
do setglobals^nullsubmerge
halt
\gtm_eof
# change AREG->ALLOW here after intially setting nullsubs values with ALWAYS
$DSE << \dse_eof
change -fileheader -null_subs=existing
exit
\dse_eof
$GTM << \gtm_eof
set lcl(2)=99
set lcl(1)="one"
set lcl(1,"")="1NULL"
set lcl(1,"",1)=88
write "checking merge on global1 when null_subs=never",!
do neverglobal^nullsubmerge
do error1neverglobal^nullsubmerge
do error2neverglobal^nullsubmerge
do error3neverglobal^nullsubmerge
halt
\gtm_eof
# change default null_subs to always now
$DSE << \dse_eof
find -region=DEFAULT
change -fileheader -null_subs=always
exit
\dse_eof
$GTM << \gtm_eof
set lcl(1)=66
set lcl(1,"")="1NULL"
set lcl(1,"",1)="1NULL1"
write "checking merge on global1 when null_subs=always",!
do alwaysglobal^nullsubmerge
halt
\gtm_eof
# change default null_subs to existing now
$DSE << \dse_eof
find -region=DEFAULT
change -fileheader -null_subs=exist
exit
\dse_eof
$GTM << \gtm_eof
set lcl(2)=99
set lcl(1)=1
set lcl(1,"")=777
set lcl(1,"",1)="1NULL1"
write "checking merge on global1 when null_subs=existing",!
do allowexistglobal^nullsubmerge
do error1^nullsubmerge
do error2^nullsubmerge
do error2sub^nullsubmerge
do error3^nullsubmerge
do error3sub^nullsubmerge
do error4^nullsubmerge
do error5^nullsubmerge
halt
\gtm_eof
