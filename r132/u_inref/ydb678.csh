#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

set hyphenstr = "--------------------------------------------------------------------------------------------------"

foreach value ("undef" "0" "no" "false" "RandomValue" "1" "yes" "true")
	if ("undef" == $value) then
		set str = "undefined"
		unsetenv ydb_treat_sigusr2_like_sigusr1
	else
		set str = "set to $value"
		setenv ydb_treat_sigusr2_like_sigusr1 $value
	endif
	echo $hyphenstr
	echo '# Verify $ZYINTRSIG is "" and $ZININTERRUPT=0 [ydb_treat_sigusr2_like_sigusr1 is '$str']'
	echo '# Also verify that ZWRITE $ZYINTRSIG works'
	echo ""
	$ydb_dist/yottadb -run zshow^ydb678

	echo $hyphenstr
	echo '# Verify $ZYINTRSIG is "SIGUSR1" and $ZININTERRUPT=1 inside $ZINTERRUPT code for SIGUSR1'
	echo '#    [ydb_treat_sigusr2_like_sigusr1 is '$str']'
	echo ""
	$ydb_dist/yottadb -run zshowonsigusr1^ydb678

	echo $hyphenstr
	echo '# Verify $ZYINTRSIG is "SIGUSR2" and $ZININTERRUPT=1 inside $ZINTERRUPT code for SIGUSR2'
	echo '#    when ydb_treat_sigusr2_like_sigusr1 is 1, "yes" or "true".'
	echo '# And that $ZINTERRUPT is NOT invoked for SIGUSR2 (i.e. $ZYINTRSIG or $ZININTERRUPT do not show up below)'
	echo '#    when ydb_treat_sigusr2_like_sigusr1 is undefined, 0, "no", "false" or "RandomValue"'
	echo ""
	$ydb_dist/yottadb -run zshowonsigusr2^ydb678
end

echo $hyphenstr
echo '# Note: Test that ZSHOW "I" displays $ZYINTRSIG is verified in other existing tests of ZSHOW "*" output'
echo '# So it is not specifically tested here'
echo ""

echo $hyphenstr
echo '# Test that $ZYINTRSIG is a read-only ISV. Setting it should issue a SVNOSET error'
echo ""
$ydb_dist/yottadb -run setisv^ydb678
echo ""

echo $hyphenstr

