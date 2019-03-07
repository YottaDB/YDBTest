#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2013 Fidelity Information Services, Inc		#
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

# This scipt tests GBLNAME qualifier.
# gde now requires collation setup to be done at the time of defining. So lets do it at the top

source $gtm_tst/com/cre_coll_sl_straight.csh 1
setenv gtm_collate_199 $gtm_collate_1
setenv gtm_collate_255 $gtm_collate_1
setenv gtm_collate_256 $gtm_collate_1
setenv gtm_collate_400 $gtm_collate_1

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/gblname.cmd'")'

echo "$GDE << gde_eof"	>>&! gblname_script.csh
cat gdegblname.cmd	>>&! gblname_script.csh
echo "gde_eof"		>>&! gblname_script.csh

chmod +x gblname_script.csh

./gblname_script.csh

$GDE << gde_eof
show -commands
ADD -GBLNAME abcd -COLLATION=0
rename -gblname abcd efgh
show -gblname
change -gblname efgh -collation=199
show -gblname
gde_eof

echo "# unset gtm_collate_199, when efgh is created with -collation=199. Expect GDE to throw YDB-E-COLLATIONUNDEF"
unsetenv gtm_collate_199
$GDE show -gblname

echo "# Now set back gtm_collate_199 and expect GDE to work"
setenv gtm_collate_199 $gtm_collate_1
$GDE show -gblname
