#!/usr/local/bin/tcsh
# test for conversion utility routines
# these are the tests in the manual

echo "EXP"
$GTM << \GTMEND
DO INT^%EXP
3
12
zwr
DO INT^%EXP

3
zwr
DO INT^%EXP
3

zwr
\GTMEND

$GTM << \GTMEND
S %I=2,%J=9
DO ^%EXP
ZWR
\GTMEND
$GTM << \GTMEND
WRITE $$FUNC^%EXP(2,9)
\GTMEND

echo "SQRROOT"
$GTM << \GTMEND
s %X=81
DO ^%SQROOT
zwr
\GTMEND

$GTM << \GTMEND
do INT^%SQROOT
81
9
3
-4

ZWR
\GTMEND

$GTM << \GTMEND
WRITE $$FUNC^%SQROOT(81)
WRITE $$FUNC^%SQROOT("-1")
\GTMEND
