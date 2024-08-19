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

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
Test the behaviour mentioned in the comment
*****************************************************************

This comment explains a regression:
https://gitlab.com/YottaDB/DB/YDB/-/issues/780#note_1937891232

> While trying to identify all scenarios which need
> documentation (see https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2007#note_1937772663
> for details on one scenario that was found as lacking
> documentation), I noticed a regression in GT.M V7.0-000.
>
> https://docs.yottadb.com/AdminOpsGuide/basicops.html#configuring-the-restriction-facility
> says the following.
>
>> If the file exists, a process that has:
>> * write authorization to restrict.txt has no restrictions;
>
> And this was true in GT.M V6.3-014, but it is not in
> GT.M V7.0-000.

If restrict.txt have *write* permission, it should be ignored,
even if it contains invalid group name, which, with no *write*
permission, considered as syntax error, and all features are
disabled.
CAT_EOF
echo ''

# set error prefix
setenv ydb_msgprefix "GTM"

echo "# set group IDs for restrict.txt"
set mygid=`id -gn`
set notmygid=`cat /etc/group | grep -vw $mygid | head -n1 | cut -d':' -f1`
set invalidgid="WhiteCrows"

echo '# prepare read-write $gtm_dist directory'
set old_dist=$gtm_dist
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
chmod -R +wX ydb_temp_dist

echo "# create database"
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out

echo "# create test cases"
rm -f $gtm_dist/restrict.txt
$gtm_dist/mumps -run perm^ydb1085 $mygid $notmygid $invalidgid > cases.txt

echo ''
foreach test ( "`cat cases.txt`" )

	set right=`echo $test | cut -d';' -f1`
	set restr1=`echo $test | cut -d';' -f2`
	set restr2=`echo $test | cut -d';' -f3`
	set restr3=`echo $test | cut -d';' -f4`
	set restr4=`echo $test | cut -d';' -f5`

	rm -f $gtm_dist/restrict.txt

	if ( "$restr1" != "" ) then
		echo "$restr1" >> $gtm_dist/restrict.txt
	endif
	if ( "$restr2" != "" ) then
		echo "$restr2" >> $gtm_dist/restrict.txt
	endif
	if ( "$restr3" != "" ) then
		echo "$restr3" >> $gtm_dist/restrict.txt
	endif
	if ( "$restr4" != "" ) then
		echo "$restr4" >> $gtm_dist/restrict.txt
	endif

	if ( -f "$ydb_dist/restrict.txt" ) then

		if ( "$right" == "ro" ) then
			chmod a-w $gtm_dist/restrict.txt
		endif
		if ( "$right" == "rw" ) then
			chmod a+w $gtm_dist/restrict.txt
		endif

		echo "# ---- restrict.txt ($right) ----"
		cat $ydb_dist/restrict.txt \
			| sed "s/$mygid/##MYGID##/g" \
			| sed "s/$notmygid/##NOTMYGID##/g" \
			| sed "s/$invalidgid/##INVALIDGID##/g"
	else
		echo "# ---- restrict.txt (does not exist) ----"
	endif

	echo '# attempt to print $ZCMDLINE in M program'
	$gtm_dist/mumps -run "hello^ydb1085" Hello, world |& cut -d':' -f1

	echo "# attempt to execute HALT instruction in M program"
	$gtm_dist/mumps -run "xhalt^ydb1085" |& cut -d':' -f1

	echo "# check direct mode"
	echo 'w $justify(5*5,3),!' \
		| $gtm_dist/mumps -dir \
		|& cut -d':' -f1 \
		| sed "s/GTM-F-RESTRICTEDOP/GTM-E-RESTRICTEDOP/g" \
		| grep -v '^YDB' \
		| grep -v '^$'

	echo '# attempt to launch DSE'
	$gtm_dist/dse 'exit' \
		|& cut -d':' -f1 \
		| grep -v "^File" \
		| grep -v '^$'

	echo ''
end

echo "# shutdown database"
setenv gtm_dist $old_dist
setenv ydb_dist $gtm_dist
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
