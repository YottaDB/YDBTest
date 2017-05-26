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

# Test various region qualifiers

# gde now requires collation setup to be done at the time of defining. So lets do it at the top
source $gtm_tst/com/cre_coll_sl_straight.csh 1

$gtm_exe/mumps -run %XCMD 'do ^gengdefile("'$gtm_tst/$tst/inref/showregion.cmd'")'

echo "$GDE << gde_eof"			>>&! showregion_script.csh
echo "show -commands -file=fresh.com"	>>&! showregion_script.csh
cat gdeshowregion.cmd			>>&! showregion_script.csh
echo "gde_eof"				>>&! showregion_script.csh

chmod +x showregion_script.csh

./showregion_script.csh

$GDE show -region
$GDE show -commands -file=final.com

echo "# Display the difference between the default show -commands and the show -commands output after modifications above"
diff fresh.com final.com

