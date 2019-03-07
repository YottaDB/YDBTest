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
# Displaying QDBRUNDOWN and GVSTATS in DSE Dump
#
foreach dir ($ydb_dist/*.gld)
	setenv ydb_gbldir $dir
	echo $dir
	echo "-----------------------------------------------"
	# Using -all for QDBRUNDOWN since it is not included in a normal DSE Dump
	$DSE dump -file -all |& $grep "Quick database rundown"
	$DSE dump -file |& $grep "gvstats" |& $tst_awk '{print "  "$5,$6,$7"		       "$8}'
	echo "-----------------------------------------------"
	echo ""
	echo ""
end

