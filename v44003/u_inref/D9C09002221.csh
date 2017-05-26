#!/usr/local/bin/tcsh -f

setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn

$gtm_tst/com/dbcreate.csh mumps

# (1) Check that when db curr_tn < MUTNWARN, TN_RESET works fine
# (2) Check that when db curr_tn > MUTNWARN, TN_RESET works fine
# (3) Check that when db curr_tn > MUTNWARN, MUPIP INTEG without TN_RESET proceeds after issuing MUTNWARN error
#

foreach version ("V4" "V6")
	if ( "V4" == $version) then
		set v3 = "CE6B27FF"
		set v4 = "D7FFFFFF"
		set v5 = "EE6B2801"
		set v6 = "F0000000"
		set v7 = "FFFFFFFF"		# This is also the max_tn value
	else
		set v3 = "CE6B27FFCE6B27FF"
		set v4 = "FFFFFFFDFFFFFFFF"
		set v5 = "FFFFFFFFA0000000"
		set v6 = "FFFFFFFFF0000000"
		set v7 = "FFFFFFFFFFFFFFFF"	# This is also the max_tn value
	endif
	# journaling might be randomly enabled by dbcreate.csh,
	# so redirect the output and grep for relevant line to keep the reference file consistent
	echo "MUPIP set -version=$version -region DEFAULT"
	$MUPIP set -version=$version -region DEFAULT >&! mupip_set_version.out
	$grep "Database file" mupip_set_version.out
	$DSE change -fileheader -max_tn=$v7
	foreach value ("AE6B2780" "BE6B27FE" $v3 $v4 $v5 $v6 $v7)
		echo "---------------------------------------------------------"
		echo "Test TN_RESET and MUTNWARN error with curr_tn = $value"
		echo "---------------------------------------------------------"
			$DSE <<DSE_EOF
			change -fileheader -warn_max_tn=$value
			change -fileheader -curr=$value
DSE_EOF
		echo ""
		echo ""
		echo "------- MUPIP INTEG without TN_RESET -------------"
		$MUPIP integ -file mumps.dat 
		echo ""
		echo "------- MUPIP INTEG with    TN_RESET -------------"
		$MUPIP integ -tn_reset -file mumps.dat 
	end
end

# (4) Check that when bitmap block transaction number equals db curr_tn, a DBMBTNSIZMX error is printed.
#	to change the bitmap block's transaction number, use curr_tn + 1 as the change -block command increments curr_tn

echo "------------------------------------------------"
echo "Test issue of DBMBTNSIZMX error from MUPIP INTEG"
echo "------------------------------------------------"
$DSE <<DSE_EOF >& dse_log	# we need to redirect because if journaling is enabled (randomly), we will see a FILERENAME message
change -file -curr=800
change -block=0 -tn=801
DSE_EOF
echo ""
echo ""

echo "------- MUPIP INTEG without TN_RESET -------------"
$MUPIP integ -file mumps.dat 
$gtm_tst/com/dbcheck.csh -noonline
