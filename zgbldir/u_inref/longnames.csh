#!/usr/local/bin/tcsh -f
#
######################################################################################
# C9D03-002250 Support Long Names
# [kishore] use of $ZGBLDIR and global variable name environments using Long Names
######################################################################################

echo "Long Names ZGBLDIR test starts ..."

# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
source $gtm_tst/com/dbcreate.csh fourreg 4
$MUPIP set -journal=enable,on,nobefore -reg "*" >& jnl_on.log
setenv gtmgbldir "threereg.gld"
$GDE << \EOF >>&! dbcreate_threereg.out
change -segment DEFAULT -file_name=threereg.dat
add -name a* -region=areg
add -name A* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=b.dat
\EOF
if("ENCRYPT" == $test_encryption) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create  -region=DEFAULT >>&! dbcreate_threereg.out
$MUPIP set -journal=enable,on,nobefore -reg DEFAULT >>& jnl_on.log
$GTM << EOF
do ^smplfil
EOF
setenv gtmgbldir "threereg.gld"
echo "*** mupip extract threereg.glo ***"
$MUPIP extract threereg.glo
echo "*** cat threereg.glo ***" 
cat threereg.glo
setenv gtmgbldir "fourreg.gld"
echo "*** mupip extract fourreg.glo ***"
$MUPIP extract fourreg.glo
echo "*** cat fourreg.glo ***" 
cat fourreg.glo

echo "Trying to forward recover after fresh mupip create"
mkdir backup
mv *.dat backup/

echo "Recreating the data files"
setenv gtmgbldir "fourreg.gld"
$MUPIP create >>&! dbcreate_fourreg_2.out
setenv gtmgbldir "threereg.gld"
$MUPIP create  -region=DEFAULT >>&! dbcreate_threereg_2.out

echo "Recovering the database"
$MUPIP journal -recover -forward a.mjl,b.mjl,c.mjl,threereg.mjl,fourreg.mjl >>& threereg_recover.log
$MUPIP extract threereg_afterrecover.glo >>& threereg_extract_afterrecover.log

setenv gtmgbldir "fourreg.gld"
$MUPIP extract fourreg_afterrecover.glo >>& fourreg_extract_afterrecover.log

foreach i (`ls *.glo`)
grep -v 'ZWR$' $i > $i.2
end

echo "diff threereg.glo.2 threereg_afterrecover.glo.2"
diff threereg.glo.2 threereg_afterrecover.glo.2
echo "diff fourreg.glo.2 fourreg_afterrecover.glo.2"
diff fourreg.glo.2 fourreg_afterrecover.glo.2

echo "Long Names ZGBLDIR test DONE."
$gtm_tst/com/dbcheck.csh
