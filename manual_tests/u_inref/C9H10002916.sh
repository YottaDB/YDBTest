#!/bin/sh
# Script that [X]INETD invokes to run the server for C9H10002916

# cd to a safe spot first
cd /testarea1/

if [ -z "$1" ]; then
    gtm_ver=V990
else
    gtm_ver=$1
fi
if [ -z "$2" ]; then
    tst_ver=T990
else
    tst_ver=$2
fi

tstdir=/testarea1/gtmtest/$gtm_ver/gtminetd
mkdir -p $tstdir
cd  $tstdir

gtm_tst=/gtc/staff/gtm_test/current/$tst_ver
gtm_dist=/usr/library/$gtm_ver/pro
gtmroutines=".($gtm_tst/manual_tests/inref $gtm_tst/com) $gtm_dist"

export gtm_dist
export gtmroutines

$gtm_dist/mumps -run c002916server

