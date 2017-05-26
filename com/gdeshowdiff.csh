#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Script to determine if two files containing GDE SHOW -ALL output are identical.
# This filters the TEMPLATES section and compares only the remaining sections (e.g. NAMES, MAPS, etc.)
# This is because GDE SHOW -COMMANDS generate a set of commands that could produce an identical output
# exception for the template section. And since that does not matter as far as the current content of the gld
# is concerned, we are fine with skipping the templates to do the diff.
#
foreach file ($1 $2)
	$tst_awk '$0 ~ /\*\*\* NAMES \*\*\*/ {printit=1} printit {print}' $file > $file.gdeshow
end
cmp $1.gdeshow $2.gdeshow
exit $status
