#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

set D = '$'
set dq = '"'
set ddq = $dq$dq

echo '# $ZCSTATUS holds an indication of the result of the last ZCOMPILE, ZLINK, $ZTRIGGER() or auto-zlink compilation'
echo '# One (1) indicates a clean compilation, a positive number greater than one is an error code you can turn into text with $ZMESSAGE(), and a negative number is a negated error code that indicates GT.M was not able to produce an object file'
echo '# The error details appear in the compilation output.'
echo '# Previously, $ZSTATUS almost always indicated a one (1) except when object file creation failed'
echo '# $ZTRIGGER() and MUPIP TRIGGER don'"'"'t install trigger definitions with XECUTE strings that do not compile without error; previously they did'
echo '# In addition, the value for $ZCSTATUS provided by ZSHOW "I" matches that provided by WRITE $ZCSTATUS; previously ZSHOW provided a zero (0) when it should have provided a one (1)'

# M files to compile
cat >> cln.m << xx
 set a=1
xx
cat >> bad.m << xx
 set a=#
xx
# Trigger files to compile
cat >> cln.trg << xx
+^a -commands=S -xecute="set a=1"
xx
cat >> bad.trg << xx
+^a -commands=S -xecute="set a=#"
xx
cat >> badE.trg << xx
+^a -commands=S -xecute="xecute ""set a=#"""
xx
cat >> clnB.trg << xx
+^b -commands=S -xecute="set a=1"
xx
cat >> badB.trg << xx
+^b -commands=S -xecute="set a=#"
xx
cat >> badEB.trg << xx
+^b -commands=S -xecute="xecute ""set a=#"""
xx

$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -r gtm9047
$gtm_tst/com/dbcheck.csh
