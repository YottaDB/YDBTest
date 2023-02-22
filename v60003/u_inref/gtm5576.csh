#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps 1

# Set the region to alternative collation.
$DSE change -file -def=1

# Create reverse collation shared library and set current GT.M collation to it.
$gtm_tst/com/cre_coll_sl.csh com/col_reverse.c 1

if ("HOST_HP-UX_PA_RISC" == "$gtm_test_os_machtype") then
	setenv ext "sl"
else
	setenv ext "so"
endif

setenv gtm_collate_1 `pwd`/libreverse.{$ext}

# Make database updates.
$gtm_exe/mumps -run %XCMD 'for i=1:1:3 set ^x(i)=i'

# Set the current GT.M collation to non-existent collation library. This should
# cause YDB-I-DLLNOOPEN and YDB-E-COLLATIONUNDEF error when tried to access the
# database values.
setenv gtm_collate_1 badcollation.{$ext}
$gtm_exe/mumps -dir <<EOF  >&! zwr.op
zwrite ^x
halt
EOF
$gtm_tst/com/check_error_exist.csh zwr.op "YDB-I-DLLNOOPEN"
$gtm_tst/com/check_error_exist.csh zwr.op "YDB-E-COLLATIONUNDEF"
$gtm_tst/com/check_error_exist.csh zwr.op "YDB-I-GVIS"


# Set the current GT.M collation to current collation library. Database access should be successful.
setenv gtm_collate_1 `pwd`/libreverse.{$ext}
$gtm_exe/mumps -r %XCMD "zwr ^x"

$gtm_tst/com/dbcheck.csh
