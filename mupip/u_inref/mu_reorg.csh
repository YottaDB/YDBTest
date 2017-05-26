#!/usr/local/bin/tcsh -f
#
######################################
# mu_reorg.csh  test for mupip reorg #
######################################
#
#
echo MUPIP REORG
echo "CORRECT FOR NEW TEST SUITE BEFORE ENABLING"
#
#
@ corecnt = 1
setenv gtmgbldir "./reorg.gld"
$gtm_tst/com/dbcreate2.csh "reorg" 128  768 1536 1000 1024  "" "" "" "reorg"  \
			  "tempre"  32  256 5632 1024  512  "" "" "" "reorga" \
  			           200 2048 3072 2048  512   "" "" "" "reorgb"
#
#
# Not breaking anything.
########################
#
#
$GTM << ffff
d fill21^myfill("set")
d fill22^myfill("set")
d fill23^myfill("set")
ffff
source $gtm_tst/$tst/u_inref/check_core_file.csh "reo" "$corecnt"
#
#
$MUPIP reorg -s="a*"
if ($status > 0) then
    echo ERROR from mupip reorg select a asterisk (normally used).
    exit 1
endif
$gtm_tst/com/dbcheck.csh "reorg"
$MUPIP reorg -s="b*"
if ($status > 0) then
    echo ERROR from mupip reorg select b asterisk (almost full database).
    exit 2
endif
$gtm_tst/com/dbcheck.csh "reorga"
$MUPIP reorg -s="c*"
if ($status > 0) then
    echo ERROR from mupip reorg select c asterisk (almost empty database).
    exit 3
endif
$gtm_tst/com/dbcheck.csh "reorgb"
#
#
$GTM << gggg
d fill21^myfill("ver")
d fill22^myfill("ver")
d fill23^myfill("ver")
gggg
source $gtm_tst/$tst/u_inref/check_core_file.csh "reo" "$corecnt"
#
#
# Shrink the database
######################
#
#
$MUPIP extract -s="b*" reobs.glo
if ($status > 0) then
    echo ERROR from mupip extract in reorg test.
    exit 4
endif
$MUPIP load -fill_factor=5 reobs.glo
if ($status > 0) then
    echo ERROR from mupip load in reorg test.
    exit 5
endif
$gtm_tst/com/dbcheck.csh "reorga"
du -a reorga.dat
$MUPIP integ -file reorga.dat >& reotg1.log
$MUPIP reorg
if ($status > 0) then
    echo ERROR from mupip reorg shrink.
    exit 6
endif
du -a reorga.dat
$MUPIP integ -file reorga.dat >& reotg2.log
#
#
grep "No errors" reotg1.log >& /dev/null
if ($status > 0) then
    echo ERROR from mupip reorg shrink integ 1.
    cat reotg1.log
    exit 7
else
    set result11 = (`fgrep Data reotg1.log`)
    echo Percentage used before reorg : $result11[4]
endif
grep "No errors" reotg2.log >& /dev/null
if ($status > 0) then
    echo ERROR from mupip reorg shrink integ 2.
    cat reotg2.log
    exit 8
else
    set result12 = (`fgrep Data reotg1.log`)
    echo Percentage used after  reorg : $result12[4]
endif
#
#
# Improve adjacency
#####################
#
#
$GTM << hhhh
f i=1:1:1000 s (^x($j(i,10)),^y($j(i,10)),^z($j(i,10)))=$j(i,55)
hhhh
source $gtm_tst/$tst/u_inref/check_core_file.csh "reo" "$corecnt"
#
#
$MUPIP integ -file reorg.dat >& reotg3.log
$MUPIP reorg
if ($status > 0) then
    echo ERROR from mupip reorg adjacency.
    exit 9
endif
$MUPIP integ -file reorg.dat >& reotg4.log
#
#
grep "No errors" reotg3.log >& /dev/null
if ($status > 0) then
    echo ERROR from mupip reorg adjancency integ 3.
    cat reotg3.log
    exit 10
else
    set result13 = (`fgrep Data reotg3.log`)
    echo Adjacency Degree before reorg : $result13[5]
endif
grep "No errors" reotg4.log >& /dev/null
if ($status > 0) then
    echo ERROR from mupip reorg adjancency integ 4.
    cat reotg4.log
    exit 11
else
    set result14 = (`fgrep Data reotg4.log`)
    echo Adjacency Degree after  reorg : $result14[5]
endif
#
#
#######################
# END of mu_reorg.csh #
#######################
