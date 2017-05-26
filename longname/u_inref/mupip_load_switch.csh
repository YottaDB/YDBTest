#!/usr/local/bin/tcsh -f
#
# MUPIP LOAD V5 data into a V4 database. Should error out.
# switch to an old version
#
set old_ver = $1
mkdir newver
mv *.dat *.gld newver 
source $gtm_tst/com/switch_gtm_version.csh $old_ver $tst_image
$gtm_tst/com/dbcreate.csh mumps
#
$MUPIP load -format=zwr v5xtract.zwr
$MUPIP extract -format=zwr v4xtract.zwr >>& v4xtract.out
# Remove the timing info
$tail -n +3 v5xtract.zwr >> v5xtract_comp.zwr
$tail -n +3 v4xtract.zwr >> v4xtract_comp.zwr
$tst_cmpsilent v4xtract_comp.zwr v5xtract_comp.zwr 
if ($status == 0) then
	echo "TEST-E-LOADSUCCESS, Was expecting MUPIP LOAD to a V4 database to fail, but it didn't!"
else
	echo "PASS, loading v5xtract.log into a V4 database did fail as expected"
endif
#
$gtm_tst/com/dbcheck.csh
