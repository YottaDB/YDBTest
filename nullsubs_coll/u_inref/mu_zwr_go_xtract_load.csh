#!/usr/local/bin/tcsh -f
#
# the script checks for MUPIP extract & load in -zwr -go format with stdnullcoll & nostdnullcoll qualifiers.
#
$MUPIP create >&! mpcreate1.out
$GTM << \gtm_eof
do two^varfill
write "global a* collates in  M.std & rest in GT.M null collation",!
zwrite ^aforavariable,^iamdefault
halt
\gtm_eof
# extract the globals from the database & use them throughout this test
$MUPIP extract 	-format=$1 extr.$1 >&! extr.out
if ($status) then
        echo "TEST-E-EXTRACT ERROR. Not able to extract in $1 format"
        exit 3
endif
rm -f a.dat mumps.dat
$MUPIP create >&! mpcreate2.out
# load the database to check for globals with same collating order
$MUPIP load -format=$1 extr.$1 >&! load1.out
if ($status) then
        echo "TEST-E-LOAD ERROR.Not able to load $1 extract"
        exit 3
endif
setenv tmpvar $1
$GTM << \gtm_eof
write "after loading the ",$ZTRNLNM("tmpvar")," extract to the database",!
write "global a* collates in  M.std & rest in GT.M null collation",!
zwrite ^aforavariable,^iamdefault
halt
\gtm_eof
#
rm -f a.dat mumps.dat
$MUPIP create >&! mpcreate3.out
# override the GDE behavior for databases & set collating orders here.
$DSE << \dse_eof
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=true
dump -fileheader
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=true
dump -fileheader
exit
\dse_eof
# load the same extract
$MUPIP load -format=$1 extr.$1 >&! load2.out
if ($status) then
        echo "TEST-E-LOAD ERROR.Not able to load $1 extract after DSE changes"
endif
$GTM << \gtm_eof
write "Collating orders changed thro' DSE",!
write "all globals collate in  M.std",!
zwrite ^aforavariable,^iamdefault
halt
\gtm_eof
rm -f a.dat mumps.dat
$MUPIP create >&! mpcreate4.out
# remove databases & change to different collating order using DSE again.
# stdnullcoll defaults to false so we need not specify it normally under DSE
# but we do here because GDE behavior for the database region AREG is still pointing to as stdnullcoll=true
$DSE << \dse_eof
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=false
dump -fileheader
find -region=DEFAULT
change -fileheader -null_subscripts=ALWAYS -stdnullcoll=true
dump -fileheader
exit
\dse_eof
# load the same extract
$MUPIP load -format=$1 extr.$1 >&! load3.out
if ($status) then
        echo "TEST-E-LOAD ERROR.Not able to load $1 extract after DSE changes"
endif
# as per the test plan AREG shoul collate in M.std but we changed here as that combination is already tested  before.
$GTM << \gtm_eof
write "collating orders again changed thro' DSE",!
write "a* globals collate in  GT.M.null collation & rest in M.std",!
zwrite ^aforavariable,^iamdefault
halt
\gtm_eof
# since the script will be called twice we move the existing data files for reference & start afresh!
mv a.dat a_$1.dat
mv mumps.dat mumps_$1.dat
#
