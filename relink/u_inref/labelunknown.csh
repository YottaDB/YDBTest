#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Verify that LABELUNKNOWN and LABELMISSING errors are not issued incorrectly with recursive relink. Relink different version of
# the same routine and expect no LABELUNKNOWN or LABELMISSING.

# Main routine.
cat > start.m <<eof
 do ^sstep
 set maxdepth=\$random(10)+5				; depth of the recursive relink
 write "maxdepth="_maxdepth,!
 do copyandlink^start("x0","x")				; link x0.m as x.m
 do ^x							; run x0.m as x.m
 quit

copyandlink(source,dest)
 new errno
 if \$&ydbposix.cp(source_".m",dest_".m",.errno)
 zcompile dest_".m"
 zlink dest
 quit

test
 zprint ^x
 do x^x
 do z^x
 quit
eof

# Routine to drive both x1.m and x2.m.
cat > x0.m <<eof
 new ver
 set ver=0
 view "LINK":"RECURSIVE"
 do copyandlink^start("x1","x")
 do ^x
 do copyandlink^start("x2","x")
 do ^x
 quit
eof

# First flavor of the routine linked from x0.m as x.m.
cat > x1.m <<eof
 new ver
 set ver=1
 quit:(\$zlevel>maxdepth)
 do copyandlink^start("x2","x")
 do test^start
 do ^x
 do test^start
 quit
x
 write "Reached label x in Version 1",!
 quit
z
 write "Reached label z in Version 1",!
 quit
eof

# Second flavor of the routine linked from x0.m as x.m.
cat > x2.m <<eof
 new ver
 set ver=2
 quit:(\$zlevel>maxdepth)
 do copyandlink^start("x1","x")
 do ^x
 quit
x
 write "Reached label x in Version 2",!
 quit
z
 write "Reached label z in Version 2",!
 quit
eof

# Invoke the main routine.
$gtm_dist/mumps -run start >&! mumps.out

# We should not see any LABELUNKNOWNs or LABELMISSINGs.
$grep -qE "(LABELUNKNOWN|LABELMISSING)" mumps.out
if (1 == $status) then
	echo "TEST-I-SUCCESS, Test succeeded."
endif
