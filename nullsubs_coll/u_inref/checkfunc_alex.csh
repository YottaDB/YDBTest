#!/usr/local/bin/tcsh -f
#
# check the behavior of functions like $ORDER with null_subscripts=EXISTING. It should not change
#
$GDE << \gde_eof
change -region default -null_subscripts=always -stdnullcoll
show -reg
exit
\gde_eof
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out 
endif

$MUPIP create
$GTM << \gtm_eof
write "set globals with null_subscripts",!
set (^aglobalvar(1),^aglobalvar(2000),^aglobalvar("CAT"),^aglobalvar(""),^aglobalvar("",1))=4906
halt
\gtm_eof
$GTM << \gtm_eof >& ALWAYS.out
do ^chkfunc
halt
\gtm_eof
$DSE << \dse_eof
change -fileheader -null_subscripts=existing
exit
\dse_eof
$DSE dump -f|& grep "Null subscripts"|$tst_awk '{print "Null subscripts changed to "$3}'
$GTM << \gtm_eof >& ALEX.out
do ^chkfunc
halt
\gtm_eof
diff ALWAYS.out ALEX.out
if ($status) then
	echo "TEST-E-ERROR. Behavior of M-Functions different for null_subscript state changes"
	echo ""
	echo ""
	cat ALEX.out
	cat ALWAYS.out
else
	echo ""
	echo ""
	echo 'PASS! BEHAVIOR NOT CHANGED FOR M-FUNCTIONS $ORDER,$NEXT,$QUERY,$ZPREVIOUS FOR EXISTING NULL_SUBS'
endif
###########################################################################
# check view undef/noundef condition for EXISTING
$GTM << \gtm_eof
view "NOUNDEF"
write ^aglobalvar("MOUSE")
view "UNDEF"
write "un-defined local var. errorexpected here as undef condition restored",!
write ^aglobalvar("MOUSE")
write "check for $DATA & $GET functions",!
write $DATA(^aglobalvar(""))
write $GET(^aglobalvar(""),"wrong value")
halt
\gtm_eof
###########################################################################
