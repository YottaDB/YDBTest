#!/usr/local/bin/tcsh -f
#################################################################
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

$gtm_tst/com/dbcreate.csh mumps 1

# max size is MAX_ZTWORMHOLE_SIZE
# grep MAX_ZTWORMHOLE_LEN gtm/sr_port/jnl.h
# #define	MAX_ZTWORMHOLE_LEN	(128 * 1024)
# #define	MAX_ZTWORMHOLE_SIZE	(MAX_ZTWORMHOLE_LEN - 512)
# #define	MAX_ZTWORM_JREC_LEN	(MAX_ZTWORMHOLE_LEN - MIN_ALIGN_RECLEN)

# Vaildate data size constraints on $ZTWOrmhole
echo "Vaildate data size constraints on ZTWOrmhole"
$GTM >& ztwormhole.log <<GTM_EOF
set max=(128*1024)-512
set \$ZTWOrmhole=\$JUSTIFY("A",max)
if max=\$Length(\$ZTWOrmhole)  write "PASS, size of \$ZTWOrmhole = ",\$Length(\$ZTWOrmhole),!
else  write "FAIL, size of \$ZTWOrmhole = ",\$Length(\$ZTWOrmhole),!
write "Try putting in too much",!
set \$ZTWOrmhole=\$JUSTIFY("A",max+1)
write "Make sure that the set did not occur. The length of ztwo should be max",!
if (max+1)=\$Length(\$ZTWOrmhole)  write "FAIL, size of \$ZTWOrmhole = ",\$Length(\$ZTWOrmhole),!
else  write "PASS, size of \$ZTWOrmhole = ",\$Length(\$ZTWOrmhole),!
GTM_EOF

#show the smaller number succeeded
$grep 'size of $ZTWOrmhole' ztwormhole.log
#show the error exists for next larger number
$gtm_tst/com/check_error_exist.csh ztwormhole.log YDB-E-ZTWORMHOLE2BIG

$gtm_tst/com/dbcheck.csh -extract
