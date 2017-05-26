#!/usr/local/bin/tcsh -f
#
$gtm_tst/com/dbcreate.csh mumps 1 255 1500 1536
setenv gtmgbldir "mumps.gld"
#
if ($?test_replic == 0) then
	$MUPIP set -journal="enable,on,before" -reg "*"
endif
#
$GTM << gtm_eof
 d ^maxrec
gtm_eof
#
#$GTM << gtm_eof2
# zwr ^var
#gtm_eof2
#
echo "Mupip extract ......"
$MUPIP extract x.ext

$switch_chset "M"
$DSE << aaa
	open -f=dse_dmp_M_glo.txt
	dump -glo -bl=3
aaa
$DSE << aaa
	open -f=dse_dmp_M_zwr.txt
	dump -zwr -bl=3
aaa
echo ""

if ("TRUE" == $gtm_test_unicode_support) then
	$switch_chset "UTF-8"
	# Expect an error while trying to use -glo in UTF8 mode
	$DSE << aaa
		open -f=dse_dmp_UTF8_glo.txt
		dump -glo -bl=3
aaa
	# Using -zwr in UTF8 mode should work though
	$DSE << aaa
		open -f=dse_dmp_UTF8_zwr.txt
		dump -zwr -bl=3
aaa
	echo ""
endif

#
echo "Journal extract ......"
$MUPIP journal -extract -forward mumps.mjl >>& ext_for.log
set stat1=$status
#
grep "Extract successful" ext_for.log
set stat2=$status
if ($stat1 != 0 || $stat2 != 0) then
	echo "C9C12002203 TEST FAILED"
	cat ext_for.log
	exit 1
endif
#
#how to compare the contents of dse_dmp.txt, x.ext and mumps.mjf while they are large
$gtm_tst/com/dbcheck.csh
