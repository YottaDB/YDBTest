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
#
#
#
echo '# Changing $zroutines to an invalid string'
$ydb_dist/mumps -run gtm8718
$grep STATUS zroutines.outx
echo ""
set zroutines1 = `head -1 zroutines.outx`
set zroutines2 = `tail -1 zroutines.outx`
if ("$zroutines1" == "$zroutines2") then
	echo '# $ZROUTINES MAINTAINED ITS ORIGINAL VALUE'
else
	echo '# $ZROUTINES CHANGED'
	echo $zroutines1
	echo $zroutines2
endif
