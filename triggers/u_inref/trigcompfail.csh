#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#trigcompfail
#
#trigcompfail, modify the contents of a trigger using DSE, execute it and get the error, then modify it back and run again
#

$gtm_tst/com/dbcreate.csh mumps 1

cat > trigcompfail.trg << TFILE
+^a -commands=SET -xecute="write ^a,!"
TFILE

$load trigcompfail.trg "" -noprompt
$show

# change write to jrite
# The following damages database to cause a compilation error in the trigger XECUTE string
alias dse_corrupt '$DSE overwrite -block=3 -offset=\!:1 -data=\!:2'

# Corrupt the 1-byte value field of the ^#t("a",1,"XECUTE") node.
# The DSE DUMP of block 3 will display something like the below
#	Rec:A  Blk 3  Off B3  Size 17  Cmpc A  Key ^#t("a",1,"XECUTE")
# In this case, we want to add 0xB3 and 0x17 and subtract 10 (length of "write ^a,!") to get the offset of the "w" byte.
# And then use that to do the corruption (change "w" to "j").
$DSE dump -block=3 >&! dse_dump_bl3.out
set corruptoffset = `$tst_awk '/XECUTE/ {a=strtonum("0x"$5)+strtonum("0x"$7)-strtonum("0xA")} END{ printf "%X\n", a}' dse_dump_bl3.out`
dse_corrupt $corruptoffset "j"

# show the trigger after butchering it
$show

# fire the trigger for an error
$GTM <<GTM_EOF
set ^a=1
GTM_EOF

# change jrite back to write
dse_corrupt $corruptoffset "w"

# fire the trigger for good output
$GTM <<GTM_EOF
set ^a=1
GTM_EOF

$gtm_exe/mupip extract trig.ext

$gtm_tst/com/dbcheck.csh
