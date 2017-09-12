#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# test mupip set with a region list
#
$GDE << xyz
add -name temp -region=temp
add -region temp -dyn=temp
add -segment temp -file=temp
xyz
if ("ENCRYPT" == "$test_encryption" ) then
	$gtm_tst/com/create_key_file.csh >& create_key_file_dbload.out
endif
$MUPIP create |& sort -f
$MUPIP set -region -access=bg DEFAULT,TEMP |& sort -f
