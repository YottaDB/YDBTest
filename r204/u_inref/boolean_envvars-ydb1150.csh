#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test that Boolean environment variables only accept substrings of yes, no, true, and false, but not superstrings'
echo '# -------------------------------------------------------------------------------------------------------------'
echo

set truthy = ( "y" "ye" "yes" "yesa" "yesab" "yesabc" "t" "tr" "tru" "true" "truea" "trueab" "trueabc" )
set falsey = ( "n" "no" "noa" "noab" "noabc" "f" "fa" "fal" "fals" "false" "falsea" "falseab" "falseabc" )
set envvars = ( "ydb_badchar" "ydb_gdscert" "ydb_noundef" "ydb_statshare" )

echo "# Create a list of the macros that internally map to the affected Boolean environment variables"
echo "# for later check to confirm that ydb_logical_truth_value() is called exactly once for each macro."
cat << CAT_EOF >&! envvar_macros.txt
YDBENVINDX_AUTORELINK_KEEPRTN
YDBENVINDX_BADCHAR
YDBENVINDX_DBFILEXT_SYSLOG_DISABLE
YDBENVINDX_DIRTREE_COLLHDR_ALWAYS
YDBENVINDX_DMTERM
YDBENVINDX_DOLLAR_TEST
YDBENVINDX_DONT_TAG_UTF8_ASCII
YDBENVINDX_ENVIRONMENT_INIT
YDBENVINDX_GDSCERT
YDBENVINDX_GVUNDEF_FATAL
YDBENVINDX_HUGETLB_SHM
YDBENVINDX_HUPENABLE
YDBENVINDX_IPV4_ONLY
YDBENVINDX_LCT_STDNULL
YDBENVINDX_NOCENABLE
YDBENVINDX_NOFFLF
YDBENVINDX_NOUNDEF
YDBENVINDX_PINSHM
YDBENVINDX_QUIET_HALT
YDBENVINDX_READLINE
YDBENVINDX_RECOMPILE_NEWER_SRC
YDBENVINDX_STATSHARE
YDBENVINDX_STDXKILL
YDBENVINDX_STP_GCOL_NOSORT
YDBENVINDX_TEST_AUTORELINK_ALWAYS
YDBENVINDX_TEST_FAKE_ENOSPC
YDBENVINDX_TREAT_SIGUSR2_LIKE_SIGUSR1
YDBENVINDX_USESECSHR
YDBENVINDX_ZQUIT_ANYWAY
YDBENVINDX_ZTRAP_NEW
CAT_EOF
echo

echo '### Test 1: Test $VIEW() shows the correct values for keywords that map to Boolean environment variables'
echo "### when those variables are set using sub- and superstrings of 'yes', 'no', 'true', and 'false'"
echo "### See the following discussion for why this is a valid test: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/831#note_2698917473"
foreach envvar ( $envvars )
	if ($envvar == "ydb_badchar") then
		if ($?gtm_chset) then
			if ($gtm_chset == "M") then
				echo "### Skipping test for ydb_badchar when running in M mode (setting ignored in this case)"
				echo
				continue
			endif
		else
			echo "### Skipping test for ydb_badchar when running in M mode (setting ignored in this case)"
			echo
			continue
		endif
	endif
	set envvar_name = $envvar
	set keyword = `echo -n $envvar | cut -f 2 -d '_'`
	echo "### Test setting ${envvar}:"
	if ($keyword == "noundef") then
		# ydb_noundef maps to $VIEW("undef"), with the "no" prefix omitted
		set keyword = "undef"
	endif
	foreach val ($truthy)
		setenv $envvar_name $val
		echo "# $envvar=${val}:"
		echo -n '  $VIEW("'"$keyword"'")='
		$gtm_dist/mumps -run %XCMD 'write $view("'$keyword'"),!'
	end

	foreach val ($falsey)
		setenv $envvar_name $val
		echo "# $envvar=${val}:"
		echo -n '  $VIEW("'"$keyword"'")='
		$gtm_dist/mumps -run %XCMD 'write $view("'$keyword'"),!'
	end
	echo
end

echo '### Test 2: Test that all macros mapping to Boolean environment variables are called by ydb_logical_truth_value() in YottaDB'
echo '### This is done to confirm appropriate sub- and superstring parsing behavior for Boolean environment variables that'
echo '### do not map to $VIEW() keywords. Fully testing these cases is not straightforward, so this is done as a workaround'
echo '### based on the fact that Test 1 above tests the correct behavior of ydb_logical_truth_value() itself. So, this test'
echo '### assumes that ydb_logical_truth_value() behaves correctly, then confirms that it is called for all affected Boolean environment variables.'
echo "### See the following discussion for why this is a valid test: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/831#note_2698917473"
echo '# Find all calls to ydb_logical_truth_value and store in a file, to avoid repeated `grep` calls in below loop over each Boolean environment variable macro'
grep -r ydb_logical_truth_value $gtm_src >&! func_calls.out
echo '# Loop over each Boolean environment variable macro and confirm that it is passed to exactly one call to ydb_logical_truth_value()'
foreach macro ( `cat envvar_macros.txt` )
	echo "# Macro ${macro} called in:"
	grep $macro func_calls.out | sed "s,$gtm_src/\(.*\.c\).*,    \1,g"
end
