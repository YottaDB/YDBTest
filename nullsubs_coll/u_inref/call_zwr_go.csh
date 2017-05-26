#!/usr/local/bin/tcsh -f
#
# 'go' format is not supported in UTF-8 mode 
# Since the intent of the subtest is explicitly do extract and load in go and zwr format, it is forced to run in M mode
$switch_chset M >&! switch_chset.out
# create database with two regions
$GDE << \gde_eof
add -name a* -region=AREG
add -region AREG -dyn=ASEG -null_subscripts=ALWAYS -stdnullcoll
add -segment ASEG -file=a.dat
change -region default -dyn=default -null_subscripts=ALWAYS -nostdnullcoll
exit
\gde_eof
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif

#
# check for mupip extratc & load using zwr format
echo ""
echo "##### MUPIP extract & load in ZWR format begins #####"
source $gtm_tst/$tst/u_inref/mu_zwr_go_xtract_load.csh zwr
echo "##### MUPIP extract & load in ZWR format ends #####"
echo ""
#
# check for mupip extratc & load using go format
echo ""
echo "##### MUPIP extract & load in GO format begins #####"
source $gtm_tst/$tst/u_inref/mu_zwr_go_xtract_load.csh go
echo "##### MUPIP extract & load in GO format ends #####"
echo ""
#
