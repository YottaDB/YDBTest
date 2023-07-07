#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
echo "# Run ydbinstall to install the current version, r1.38, r1.36"
$sudostr ./ydbinstall --utf8 --installdir $PWD/current $installoptions
foreach version ("r1.38" "r1.36")
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

	foreach dir ("current" "r1.38" "r1.36")
		echo "# $dir"
		setenv ydb_dist $PWD/$dir
		$ydb_dist/yottadb -run %XCMD 'zwrite $zroutines,$zchset,$zyrelease'
	end
end

# clean up the install directory since the files are owned by root and can't be gzipped by the test system
foreach dir ("current" "r1.38" "r1.36")
	$sudostr rm -rf $PWD/$dir
end
