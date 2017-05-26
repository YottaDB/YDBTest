#!/usr/local/bin/tcsh 
# test for conversion utility routines
# these are the tests in the manual

set cnt = 1
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << GTMEND
do INT^%DH
12
1
ZWR
GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << GTMEND
SET %DH=12
do ^%DH
ZWR
GTMEND


echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
W $$FUNC^%DH(12,4)
W $$FUNC^%DH(12)
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%DO
12
4
ZWR
DO INT^%DO
12

ZWR
DO INT^%DO
12
2
ZWR
H
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %DO=12
do ^%DO
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE $$FUNC^%DO(12,7)
WRITE $$FUNC^%DO(12)
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
do INT^%HD
E
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
set %HD="E"
DO ^%HD
zwr
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE "E:",$$FUNC^%HD("E")
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE "-1:",$$FUNC^%HD("-1")
WRITE "0:",$$FUNC^%HD("0")
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%HO
C3
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %HO="C3"
do ^%HO
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
WRITE "C3:",$$FUNC^%HO("C3")
zwr
WRITE "-1:",$$FUNC^%HO("-1")
zwr
WRITE $$FUNC^%HO("-1")
WRITE "0:",$$FUNC^%HO("0")
\GTMEND


echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%LCASE
LABEL
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
set %S="HeLLO"
w %S
d ^%LCASE
w %S
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
set X="HeLLo"
w "X:",X," $$FUNC^%LCASE(X):",$$FUNC^%LCASE(X)
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%OD
14
zwr
DO INT^%OD
-1
zwr
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
SET %OD=14
do ^%OD
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
W $$FUNC^%OD(14)
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
DO INT^%OH
16
ZWR
DO INT^%OH
89
ZWR
DO INT^%OH
-1
ZWR
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
set %OH=16
DO ^%OH
zwr
set %OH=-1
DO ^%OH
zwr
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
write "1234:",$$FUNC^%OH(1234)
write "1294:",$$FUNC^%OH(1294)
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
do INT^%UCASE
test
\GTMEND

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << \GTMEND
s X2345678="hellO of variable X2345678"
s X234567890123456789012345678901="hellO of variable X2345678901..."
w "X2345678:",X2345678," ^%UCASE(X2345678):",$$FUNC^%UCASE(X2345678)
w "X2345678901...:",X234567890123456789012345678901," ^%UCASE(X234567890123456789012345678901):",$$FUNC^%UCASE(X234567890123456789012345678901)
\GTMEND
