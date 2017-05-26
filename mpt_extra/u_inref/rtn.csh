#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2003-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# test for conversion utility routines
# these are the tests in the manual

$gtm_tst/com/dbcreate.csh .
setenv save_gtmroutines "$gtmroutines"
setenv gtmroutines ".($gtm_tst/$tst/inref .) $gtm_exe ./rtns"
# if the chset is UTF-8 over write gtmroutines as appropriate
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) setenv gtmroutines ".($gtm_tst/$tst/inref .) $gtm_exe/utf8 ./rtns"
endif
#
#setenv gtmroutines "$gtmroutines ./rtns"
mkdir rtns
foreach i (rtn rtnx tmpy tmpz t rtn1 rtn45678 rtn456789 rtn45678901234567890 rtn4567890123456789012345678901 abcd zz )
	set fname = "rtns/${i}.m"
	echo "$i	;; " >&! $fname
	echo "	;; This is the description for $i" >>&! $fname
	echo "	; Some more description" >>&! $fname
	echo "	; Yet more description" >>&! $fname
	echo "	; Yada yada ya	da" >>&! $fname
	echo "	; Yada yada ya	da" >>&! $fname
	echo '	w "This is '$i'",!' >>&! $fname
	echo '	w "Some text here",!' >>&! $fname
	echo "	q" >>&! $fname
	$convert_to_gtm_chset $fname
end

#test for %RO
cat >&! zhello.m << EOF
zhello
    ; regular comment
	;; double comment
	; another regular comment
; comment with no preceding spaces
;; double comment with no preceding spaces
label	write "Line of code with no preceding spaces",!
 	; whitespace below

	; blank line below

	write "Hello",!
	write "Line with a quoted semicolon; and comment here ->",!   ;heres the comment
	write "Line with quotes and semicolons; ""word;"" bye;",!     ;heres the comment
	write "Line with quotes and semicolons; ""word;spacing"" bye;spacing",!     ;heres the comment
	q
EOF

set cnt = 1
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
D ^%FL
?
%*
rtn*
?D
-%*
-*
rtn*
-rtn?
rt?x
%G
?D


EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
D ^%FL
rt?x
tmp*
%G

fl.out

EOF
ls fl.out
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
D ^%FL

EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
D ^%RCE
rtn*
-rtnx
?D
?
%D
-%D
?D

yada ya	da
YA	DA YADA



zwr
EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RCE
rtn*

YADA
yada
?
?D

output
EOF
cat output
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RCE
rtn*

yada
TADA
n
zwr
EOF
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RCE
rtnnon

zwr
EOF
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RCE
rtn*


zwr
EOF
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
cat rtns/rtn1.m
$GTM << EOF
d ^%RSEL
rtn1

s %ZF="TADA"
s %ZN="TADAAA"
S %ZC=1
d CALL^%RCE
zwr
EOF
cat rtns/rtn1.m

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RD
?
a:v
%D
tmp?
%D
rtn?

zwr
EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RO
?
rtn*
tmp:tmpz
-tmp
-*
rtnx
tmpy
zhello


LABEL
Y
zwr
EOF
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RO
rtnx
tmpy

file.ro
LABEL

EOF
ls  file.ro

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d CALL^%RO

d ^%RSEL
rtn1
rtnx

d CALL^%RO
s %ZD="callro.ro"
d CALL^%RO
EOF
ls -l callro.ro

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
rm rtns/rtnx.m
rm rtns/tmpy.m
$GTM << EOF
d ^%RI

?
file.ro

zwr
EOF
ls {rtnx.m,tmpy.m}

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RSE
rtn*
?
?D
tmp*
-rtn*

Yada

zwr
EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RSE
rtn*
?
?D
tmp?
-rtn*

ya	da

zwr
EOF

rm -f callrse.out
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d CALL^%RCE
d ^%RSEL
rtn1
zz

d CALL^%RSE
s %ZF="text here"
d CALL^%RSE
zwr
s %ZD="callrse.out"
open %ZD
d CALL^%RSE
zwr
EOF
cat callrse.out

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RSEL
rtn*
-r?nx
?D
?
-rt?4
tmpy
'tmpy
%D
-%D
?D

zwr
EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d ^%RSEL
rtn*

zwr
d ^%G

*

s %ZRSET=1
d ^%RSEL
rtn*

zwr
m RSET=^%RSET(\$j)
zwr RSET
k RSET
i \$D(^%RSET) k ^%RSET
k %ZR
d OBJ^%RD
rtn*

zwr
if \$D(^%RSET) zwr ^%RSET k ^%RSET
d SRC^%RD
rtn*

zwr
if \$D(^%RSET) zwr ^%RSET k ^%RSET
d LIB^%RD
zwr
if \$D(^%RSET) zwr ^%RSET k ^%RSET
d CALL^%RSEL
rtn1

d CALL^%RSEL
rtn45678

h
EOF

$gtm_exe/mumps -run rseltest << EOF
rtnx
rtn4567890123456789012345678901

?D
tmp*
rtn45678901234567890
-rtn4567890123456789012345678901
?D

EOF

$gtm_exe/mumps -run rseltest << EOF
rtnx
rtn4567890123456789012345678901

?D
tmp*
rtn45678901234567890
-rtn4567890123456789012345678901
?D

EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
$GTM << EOF
d CALL^%RSEL
rtn1

zwr
d CALL^%RSEL
rtn45678

zwr
d CALL^%RSEL
rtnx

zwr
EOF

echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
rm *.o
$gtm_exe/mumps rtnx.m
$gtm_exe/mumps rtns/tmpz.m
rm rtns/tmpz.m
echo $gtmroutines
$GTM << EOF
W "%RSEL",!
d ^%RSEL
rtn*
tmp*

w "OBJ:",!
d OBJ^%RSEL
rtn*
tmp*

w "SRC:",!
d SRC^%RSEL
rtn*
tmp*

EOF

echo "#####################"$cnt"###################"
$gtm_exe/mumps rtn*.m
rm rtns/rtn{1,45678}.m
@ cnt = $cnt + 1
$GTM << EOF
w "OBJ:",!
d OBJ^%RD
rtn*
tmp*

w "SRC:",!
d SRC^%RD
rtn*
tmp*

w "LIB:",!
d LIB^%RD
zwr
EOF

# ---------------------------------
# Test for C9F10-002758
# ---------------------------------
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
cp $gtm_tst/$tst/inref/XUS2.RTN .
$GTM << EOF
d ^%RI

?
XUS2.RTN

zwr
EOF
ls XUS2.m

# ---------------------------------
# Test for gtm7658 - form-feed (<FF>) terminated routines
# ---------------------------------
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
cp $gtm_tst/$tst/u_inref/gtm7658.ro .
$GTM << EOF
d ^%RI
y
gtm7658.ro
rtns
zwr
EOF
ls -1 rtns/_D?.m

# ---------------------------------
# Test for gtm7658 -  strip <CR>s from DOS style formatted input
# ---------------------------------
echo "#####################"$cnt"###################"
@ cnt = $cnt + 1
cp $gtm_tst/$tst/u_inref/gtm7658d.ro .
$GTM << EOF
d ^%RI

gtm7658d.ro

zwr
d ^foo
EOF
ls foo.m

setenv gtmroutines "$save_gtmroutines"
$gtm_tst/com/dbcheck.csh
