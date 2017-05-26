#!/usr/local/bin/tcsh
# test for date/time utility routines
# these are the tests in the manual

set cnt = 1
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %DS="10/20/2002"
DO INT^%DATE
ZWR
h
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE $$FUNC^%DATE("10/20/2002")
H
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %DT=59097  DO %CDS^%H
ZWR
H
\GTMEND


echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %DT="10/20/2002" DO %CDN^%H
ZWR
H
\GTMEND


echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %TM=63678 DO %CTS^%H
ZWR
H
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %TM="17:41:18" DO %CTN^%H
ZWR
H
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE $$CDS^%H(59130)
WRITE $$CDN^%H("11/22/2002")
WRITE $$CTS^%H(59130)
WRITE $$CTN^%H("16:25:30")
H
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO ^%T
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%T
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
write $$FUNC^%T
H
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO ^%TI
4:02 PM
ZWR
DO ^%TI
1602
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%TI
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %TS="8:30AM"
d INT^%TI
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE $$FUNC^%TI("8:30AM")
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO ^%TO
zwr
S %TN=62074
DO ^%TO
zwr
h
\GTMEND

