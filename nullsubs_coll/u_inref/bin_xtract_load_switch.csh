#!/usr/local/bin/tcsh -f
#
setenv gtm_test_mupip_set_version "disable"
# switch to an older version
set old_ver = $1
source $gtm_tst/com/switch_gtm_version.csh $old_ver $tst_image
# create a old version database
$gtm_tst/com/dbcreate.csh mumps
# allow null subscripts
$DSE << dse_eof
change -fileheader -null_subscript=true
dump -fileheader
exit
dse_eof
# set globals
$GTM << \gtm_eof
write $ZV,!
do one^varfill
write "The globals should be in GT.M null-collation order",!
zwrite ^aglobalv
halt
\gtm_eof
$gtm_tst/com/dbcheck.csh
# extract the data
$MUPIP extract -format=bin v4_extr.bin >& v4_extr.out
# delete the database & gld file before switching to the version being tested
rm -f mumps.dat mumps.gld
# switch to version being tested
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$gtm_tst/com/dbcreate.csh mumps
$DSE << dse_eof
change -fileheader -null_subscript=always -stdnullcoll=TRUE
dump -fileheader
exit
dse_eof
$gtm_tst/com/dbcheck.csh
# Load old version data into the version being tested database.
$MUPIP load -format=bin v4_extr.bin >&v4_load1.out
if ($status) then
        echo "TEST-E-LOAD ERROR.Not able to load old version data into new version databse"
        exit 3
else
        echo "Successful load of old version data into the version being tested"
endif
$GTM << \gtm_eof
write $ZV,!
write "The globals should be in M standard null-collation order",!
zwrite ^aglobalv
kill ^aglobalv
halt
\gtm_eof
# change collation order
$DSE << dse_eof
change -fileheader -stdnullcoll=FALSE
dump -fileheader
exit
dse_eof
# load again the same old version extract
$MUPIP load -format=bin v4_extr.bin >&v4_load2.out
if ($status) then
        echo "TEST-E-LOAD ERROR.Not able to change collation order & load old version data into new one"
else
        echo "Successful load of old version data into the version being tested after changing collation order"
endif
$GTM << \gtm_eof
write $ZV,!
write "The globals should be in GT.M null-collation order",!
zwrite ^aglobalv
halt
\gtm_eof
#
