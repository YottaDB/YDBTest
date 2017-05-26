#!/usr/local/bin/tcsh -f

# This test cannot run in UTF8 mode as it plays with a lot of $CHARs
$switch_chset "M" >& switch_chset.log

$gtm_dist/mumps $gtm_tst/$tst/inref/cmclient.m $gtm_tst/$tst/inref/cminit.m $gtm_tst/$tst/inref/connect.m $gtm_tst/$tst/inref/cvt.m $gtm_tst/$tst/inref/define.m $gtm_tst/$tst/inref/disc.m $gtm_tst/$tst/inref/get.m $gtm_tst/$tst/inref/header.m << xxyx
xxyx
$gtm_dist/mumps $gtm_tst/$tst/inref/kill.m $gtm_tst/$tst/inref/lock.m $gtm_tst/$tst/inref/next.m $gtm_tst/$tst/inref/order.m $gtm_tst/$tst/inref/query.m $gtm_tst/$tst/inref/set.m $gtm_tst/$tst/inref/setpiece.m $gtm_tst/$tst/inref/tcp.m $gtm_tst/$tst/inref/unlock.m $gtm_tst/$tst/inref/unlockcl.m << xxyy
xxyy
$gtm_dist/mumps $gtm_exe/*.m
#switching journals on the fly.
$gtm_tst/$tst/u_inref/tstswjnl.csh
