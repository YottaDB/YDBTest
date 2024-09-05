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
GTM-F167559 - Test the following release note
*****************************************************************

Release note http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-F167559 says:

> MUPIP CREATE creates V6 (V6.3-014) database files when the
> environment variable gtm_db_create_ver is defined as [V]6,
> or when the command line specifies: -V6. The -NOV6 command
> line option allowing overrides a gtm_db_create_ver and creates
> a V7 database file. This means this V7 release can operate
> seamlessly with V6 databases. Prior V7 versions did not have
> this support. (GTM-F167559)
CAT_EOF

# set error prefix
setenv ydb_msgprefix "GTM"

foreach opts ( \
		"7/none//" \
		"7/env_7/7/" \
		"7/env_v7/V7/" \
		"6/env_6/6/" \
		"6/env_v6/V6/" \
		"6/cli_v6//-V6" \
		"6/env_7_cli_v6/7/-V6" \
		"7/env_6_cli_nov6/6/-NOV6" \
		"7/env_v6_cli_nov6/V6/-NOV6" \
	)

	set expected=`echo $opts | cut -d/ -f1`
	set case=`echo $opts | cut -d/ -f2`
	set env_db_ver=`echo $opts | cut -d/ -f3`
	set mupip_cli_opt=`echo $opts | cut -d/ -f4`

	echo
	echo "# ---- case ${case} ----"

	echo '# set $gtmgbldir =' ${case}.gld
	setenv gtmgbldir ${case}.gld

	if ("$env_db_ver" != "") then
		echo '# set $<gtm|ydb>_db_create_ver =' ${env_db_ver}
		source $gtm_tst/com/set_ydb_env_var_random.csh \
			ydb_db_create_ver \
			gtm_db_create_ver \
			${env_db_ver}
	else
		$gtm_tst/com/unset_ydb_env_var.csh \
			ydb_db_create_ver \
			gtm_db_create_ver
	endif

	echo "# execute: GDE change -segment default -file=${case}.dat"
	$gtm_dist/mumps -run GDE \
		"change -segment default -file=${case}.dat" \
		>& gde-${case}.out
	echo "# execute: mupip create ${mupip_cli_opt}" | sed 's/ $//g'
	$gtm_dist/mupip create ${mupip_cli_opt} \
		>& mupip-${case}.out
	echo "# check whether db file ${case}.dat is created:"
	ls -1 ${case}.dat

	echo "# display db version of ${case}.dat, should be v${expected}:"
	set result=`$gtm_dist/mumps -run getDbVer ${case}.dat`
	echo -n "$result - "
	if ("$result" == "$expected") then
		echo pass
	else
		echo FAIL
	endif
end
