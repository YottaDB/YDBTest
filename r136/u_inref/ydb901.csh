#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# SIG-11 when compiling with -NOLINE_ENTRY if M code contains a BREAK or NEW'
echo '# This test runs multiple samples that previously crashed if compiled with -noline_entry'
echo '# When it runs now, no output is expected, which is what we want'

setenv gtmcompile "-noline_entry"

echo '# BREAK No label, first line code'
cat >> ydb901a.m << xx
	IF 0 BREAK
	SET X=""
xx
$gtm_exe/mumps -run ydb901a

echo '# BREAK First line label no code, second line code'
cat >> ydb901b.m << xx
ydb901b
	IF 0 BREAK
	SET X=""
xx
$gtm_exe/mumps -run ydb901b

echo '# BREAK First line label followed by M code'
cat >> ydb901c.m << xx
ydb901c IF 0 BREAK
	SET X=""
xx
$gtm_exe/mumps -run ydb901c

echo '# BREAK First line comment, M code eventually follows after comments'
cat >> ydb901d.m << xx
	;
	IF 0 BREAK
	SET X=""
xx
$gtm_exe/mumps -run ydb901d

echo '# BREAK First line empty, code follows'
cat >> ydb901e.m << xx

	IF 0 BREAK
	SET X=""
xx
$gtm_exe/mumps -run ydb901e

echo '# BREAK Use one local variable BEFORE the BREAK followed by a local variable reference in the next line'
cat >> ydb901f.m << xx
	SET i=1 IF 0 BREAK
	NEW k
xx
$gtm_exe/mumps -run ydb901f

##### NEW COMMANDS NEXT -->
$echoline
##### NEW COMMANDS NEXT <--

echo '# NEW No label, first line code'
cat >> ydb901g.m << xx
	IF 0 NEW
	SET X=""
xx
$gtm_exe/mumps -run ydb901g

echo '# NEW First line label no code, second line code'
cat >> ydb901h.m << xx
ydb901h
	IF 0 NEW
	SET X=""
xx
$gtm_exe/mumps -run ydb901h

echo '# NEW First line label followed by M code'
cat >> ydb901i.m << xx
ydb901i IF 0 NEW
	SET X=""
xx
$gtm_exe/mumps -run ydb901i

echo '# NEW First line comment, M code eventually follows after comments'
cat >> ydb901j.m << xx
	;
	IF 0 NEW
	SET X=""
xx
$gtm_exe/mumps -run ydb901j

echo '# NEW First line empty, code follows'
cat >> ydb901k.m << xx

	IF 0 NEW
	SET X=""
xx
$gtm_exe/mumps -run ydb901k

echo '# NEW Use one local variable BEFORE the BREAK followed by a local variable reference in the next line'
cat >> ydb901l.m << xx
	SET i=1 IF 0 NEW
	NEW k
xx
$gtm_exe/mumps -run ydb901l
