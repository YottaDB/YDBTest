#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# Test to see if ydbinstall can successfully install older versions (to catch issue fixed in YDB\!1360, YDB@aed0e780)'

# Note that this test just tests up to r1.36 because r1.34 does not install on SUSE systems that are part of the testing system
source $gtm_tst/$tst/u_inref/setinstalloptions.csh	# sets the variable "installoptions" (e.g. "--force-install" if needed)
echo "# Copy ydbinstall to this directory (don't want it thinking it is installing the working version)"
cp /Distrib/YottaDB/$gtm_verno/$tst_image/yottadb_r*/ydbinstall .
echo "# Run ydbinstall to install the current version, r2.00, r1.38"
$sudostr ./ydbinstall --utf8 --installdir $PWD/current $installoptions
foreach version ("r2.00" "r1.38")
	if (("r1.38" == $version) && $gtm_test_rhel9_plus) then
		# RHEL 9 does not have a r1.38 tarball so skip this step there
		continue
	endif
	$sudostr ./ydbinstall --utf8 --installdir $PWD/$version $installoptions $version
end

foreach mode ("M" "UTF-8")
	echo
	echo "# Testing $mode Mode"
	$switch_chset $mode
	unsetenv gtmroutines
	unsetenv ydb_routines
	unsetenv gtm_dist
	unsetenv ydb_dist

	foreach dir ("current" "r2.00" "r1.38")
		if (("r1.38" == $dir) && $gtm_test_rhel9_plus) then
			# RHEL 9 does not have a r1.38 tarball so skip this step there
			continue
		endif
		echo "# $dir"
		setenv ydb_dist $PWD/$dir
		# Note that at this point "ydb_routines" and "gtmroutines" env vars are unset.
		# This means $zroutines will be set to $ydb_dist/libyottadbutil.so at process startup.
		if (`where execstack` != "") then
			# "execstack" utility/command is installed on this system.
			# Use it to mark $ydb_dist/libyottadbutil.so as not requiring executable stack.
			# This is because libyottadbutil.so before r2.04 did not clear this bit explicitly
			# and that meant Ubuntu 25.04 considered that case as requiring executable stack
			# resulting in a DLLNOOPEN error.
			if ("M" == $mode) then
				# libyottadbutil.so used will be under $ydb_dist
				set subdir = ""
			else
				# libyottadbutil.so used will be under $ydb_dist/utf8
				set subdir = "utf8/"
			endif
			$sudostr execstack --clear-execstack $ydb_dist/${subdir}libyottadbutil.so
		endif
		$ydb_dist/yottadb -run %XCMD 'zwrite $zroutines,$zchset,$zyrelease'
	end
end

# clean up the install directory since the files are owned by root and can't be gzipped by the test system
foreach dir ("current" "r2.00" "r1.38")
	if (("r1.38" == $dir) && $gtm_test_rhel9_plus) then
		# RHEL 9 does not have a r1.38 tarball so skip this step there
		continue
	endif
	$sudostr rm -rf $PWD/$dir
end
