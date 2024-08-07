#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "###########################################################################################################"
echo '# Test that $ZEXTRACT does not behave like $EXTRACT in UTF-8 mode for literal parameters'
echo "###########################################################################################################"

$gtm_dist/mumps -run ydb1093

