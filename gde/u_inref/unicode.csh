#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$switch_chset "UTF-8" >&! switch_utf8.log
# The test uses collation 1, which should be defined before using
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/unicode.cmd'")'
cp gdeunicode.cmd gdeunicode.cmd_orig
sed 's/\$/\\\$/g' gdeunicode.cmd_orig >&! gdeunicode.cmd

echo "$GDE << gde_eof"	>>&! unicode_script.csh
cat gdeunicode.cmd		>>&! unicode_script.csh
echo "gde_eof"		>>&! unicode_script.csh

chmod +x unicode_script.csh

./unicode_script.csh

$GDE show -map >&! show_map.out
$grep "REG =" show_map.out

