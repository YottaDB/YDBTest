#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019-2022 YottaDB LLC and/or its subsidiaries.	#
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

echo '# When the second and third argument of $TRANSLATE are literals, the GT.M compiler calculates the tables used by the translation'
echo '# Previously the tables were always prepared at run-time'

echo; echo '# compiling $translate("qwerty","werty","uickl") to assembly'
cp $gtm_tst/$tst/inref/gtm8947A.m .
$gtm_dist/mumps -machine -lis=gtm8947A.lis gtm8947A.m
echo '# greping for "OC_FNZTRANSLATE_FAST|OC_FNTRANSLATE_FAST" which should not appear if optimized correctly'
grep 'OC_FN\(Z\?\)TRANSLATE_FAST$' gtm8947A.lis
echo "grep status Expected: 1; Actual: $status"

set strB='# compiling $translate("qwerty","werty",^a) to assembly'
set strC='# compiling $translate("qwerty",^a,"uickl") to assembly'
set strD='# compiling $translate("qwerty",^a,^b) to assembly'
foreach i (B C D)
	echo; echo `eval echo '${'str${i}'}'`
	cp $gtm_tst/$tst/inref/gtm8947$i.m .
	$gtm_dist/mumps -machine -lis=gtm8947$i.lis gtm8947$i.m
	echo '# greping for "OC_FNZTRANSLATE_FAST|OC_FNTRANSLATE_FAST" which should not appear if optimized correctly'
	grep 'OC_FN\(Z\?\)TRANSLATE_FAST$' gtm8947$i.lis
	echo "grep status Expected: 1; Actual: $status"
end
