#################################################################
#								#
# Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test that ps identifies JOB'd process with the same name as the parent"
$gtm_tst/com/dbcreate.csh mumps

echo '# Add $ydb_dist to PATH to verify JOB command works fine even in that case'

foreach exe (mumps yottadb)
	foreach pathname ("$ydb_dist/" "")
		echo '# Invoking command --> '${pathname}${exe}' -run ydb592 : Expecting jobbed child to show up as "'$exe'" in ps output'
		if ("" == "$pathname") then
			# Add $ydb_dist to $PATH
			set origpath=($path)
			set path=($ydb_dist $origpath) #YottaDB is now in /usr/local/bin so $ydb_dist now must be first in path so that it gets picked up first.
		endif
		${pathname}${exe} -run ydb592
		if ("" == "$pathname") then
			# Restore $PATH
			set path=($origpath)
		endif
		set filename = `echo *.mjo`
		cat $filename
		mv $filename $filename.$exe.${pathname:h:t}
	end
end
echo '# Invoking command --> YottaDB runtime through ydb_ci() : Expecting jobbed child to show up as "yottadb" in ps output'
# Setup call-in table
setenv ydb_ci `pwd`/tab.ci
cat >> tab.ci << xx
ydb592:		void	^ydb592()
xx

set file = "ydb592"
$gt_cc_compiler $gt_cc_shl_options $gtm_tst/$tst/inref/$file.c -I $ydb_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$ydb_dist -L$ydb_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
	exit 1
endif
rm -f link.map
rm -f $file.o	# remove .o file corresponding to .c file as it will be needed to create .o corresponding to .m file inside call-in
`pwd`/$file
set filename = `echo *.mjo`
cat $filename
mv $filename $filename.callin

$gtm_tst/com/dbcheck.csh

