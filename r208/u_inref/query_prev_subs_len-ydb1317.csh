#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1317] $QUERY() of a local whose last subscript is "" returns the right node after an earlier  #'
echo '# $QUERY() of that local returned another node whose last subscript is ""                            #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# To tell a request for the first or last node at a level from a call that continues a $QUERY() loop,'
echo '# $QUERY() of a local compares its input with the previous $QUERY() result. That check treated string'
echo '# subscripts of different lengths as equal, and it compared a saved subscript in its formatted form,'
echo '# such as "b", with the input subscript b. So a $QUERY() of y("b","") right after a $QUERY() that'
echo '# returned y("aa","") took y("b","") for that result and returned a wrong node.'
echo '#'
echo '# Each check names the result it expects. Stages 1 to 3 print WRONG for the checks right after a'
echo '# $QUERY() that returned y("aa","") without the fix. Stages 4 and 5 pass without the fix too; they'
echo '# check that a $QUERY() loop still continues from the previous result now that the saved subscripts'
echo '# are kept in their unformatted form across garbage collections. Stages 2 to 5 use reverse $QUERY(),'
echo '# which only YottaDB has, so they run only with a YottaDB build.'
echo '#'
echo '# Each stage runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1317.m $gtm_tst/$tst/inref/ydb1317rev.m .
# The checks assume that local subscripts use the default M collation sequence (no ydb_local_collate),
# since an alternative collation sequence would change the order of the nodes. Each stage sets the
# null collation (ydb_lct_stdnull) itself.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_local_collate gtm_local_collate

echo '# Stage 1 : forward $QUERY() of a local with GT.M null collation'
echo '# Command : $gtm_dist/mumps -run gtmfwd^ydb1317 (with ydb_lct_stdnull=0)'
echo '#   expect each check to return the node named, including y("b",5) right after a $QUERY() that'
echo '#   returned y("aa","")'
echo '#   previously "" right after a $QUERY() that returned y("aa",""), since that call took y("b","") for'
echo '#   the previous result'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 0
$gtm_dist/mumps -run gtmfwd^ydb1317
echo

if ($gtm_exe:h:t =~ V*_R*) then
	# Reverse $QUERY() is a YottaDB feature, so stages 2 to 5 run only with a YottaDB build
	echo '# Stage 2 : reverse $QUERY() of a local with standard null collation'
	echo '# Command : $gtm_dist/mumps -run stdrev^ydb1317rev (with ydb_lct_stdnull=1)'
	echo '#   expect each check to return the node named, including y("b",5), and y("b","a") when y("b","")'
	echo '#   has no value, right after a $QUERY() that returned y("aa","")'
	echo '#   previously y("aa","") in both of those checks'
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 1
	$gtm_dist/mumps -run stdrev^ydb1317rev
	echo

	echo '# Stage 3 : reverse $QUERY() of a local with GT.M null collation'
	echo '# Command : $gtm_dist/mumps -run gtmrev^ydb1317rev (with ydb_lct_stdnull=0)'
	echo '#   expect each check to return the node named, including y("b","") right after a $QUERY() that'
	echo '#   returned y("aa","")'
	echo '#   previously y("b",5) in that check'
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 0
	$gtm_dist/mumps -run gtmrev^ydb1317rev
	echo

	echo '# Stage 4 : forward and reverse $QUERY() loops over 400 random trees, standard null collation'
	echo '# Command : $gtm_dist/mumps -run walk^ydb1317rev (with ydb_lct_stdnull=1)'
	echo '#   expect both loops to visit every node with a value once, the reverse loop in the reverse order'
	echo '#   previously the same result'
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 1
	$gtm_dist/mumps -run walk^ydb1317rev
	echo

	echo '# Stage 5 : forward and reverse $QUERY() loops over 400 random trees, GT.M null collation'
	echo '# Command : $gtm_dist/mumps -run walk^ydb1317rev (with ydb_lct_stdnull=0)'
	echo '#   expect both loops to visit every node with a value once, the reverse loop in the reverse order'
	echo '#   previously the same result'
	source $gtm_tst/com/set_ydb_env_var_random.csh ydb_lct_stdnull gtm_lct_stdnull 0
	$gtm_dist/mumps -run walk^ydb1317rev
	echo
endif

source $gtm_tst/com/unset_ydb_env_var.csh ydb_lct_stdnull gtm_lct_stdnull
echo "# Done"
