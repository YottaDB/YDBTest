#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# test the following commands:
# zlink
# zcompile
# zedit
# zprint
# do
# goto/zgoto
# job


$gtm_tst/com/dbcreate.csh . . 200

\rm -f *.o >&! rm_star_o.out	# Since the test lists .o files, remove all object files created by dbcreate and friends

setenv EDITOR "$gtm_tst/$tst/u_inref/zed.csh"
$GTM << aaa
 write "do ^routine",! do ^routine
aaa
### ZGOTO and indirect and full entry references:
# C9E11-002669 ZGOTO fails with indirect entry references
# C9D06-002318 ZGOTO interaction with autozlink.
$GTM << gtm_end
write "zgoto 1:b2345678^routinex",!
zgoto 1:b2345678^routinex
write "don't come back",!
gtm_end
\rm -f routinex.o

$GTM << gtm_end
write "zgoto 1:^@b",!
set b="routinex"
zgoto 1:^@b
write "don't come back",!
gtm_end
\rm -f routinex.o

$GTM << gtm_end
write "zgoto 1:@c^@b",!
set c="b2345678",b="routinex"
zgoto 1:@c^@b
write "don't come back",!
gtm_end
\rm -f routinex.o

$GTM << gtm_end
do ^testzg("lc")
gtm_end
\rm -f routinex.o

$GTM << gtm_end
do ^testzg("ld")
gtm_end
\rm -f routinex.o

# If there is a prior ZLINK, the direct mode ZGOTO (with full entryref) also works:
$GTM << gtm_end
zlink "routinex"
do ^testzg("ld")
gtm_end

$gtm_tst/com/dbcheck.csh
