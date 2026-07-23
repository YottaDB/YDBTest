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
echo "# Test that ydbinstall --gtm installs GT.M from every SourceForge folder FIS uses (YDB#1242)"
echo "#"
echo "# FIS published GT.M V7.2-000 under a new SourceForge folder (GT.M-x8664-Linux) while V7.1-011 and"
echo "# older releases stayed in the original folder (GT.M-amd64-Linux). ydbinstall only ever looked in"
echo "# the latter, so 'ydbinstall --gtm V7.2-000' failed with 'Unable to download GT.M distribution'."
echo "# FIS also stopped maintaining the 'latest' file that ydbinstall read to resolve a bare '--gtm', so"
echo "# that kept resolving to the stale V7.1-011 no matter what FIS released."

source $gtm_tst/$tst/u_inref/setinstalloptions.csh	# sets the variables "installoptions" and "sudostr"

echo ""
echo "# Copy ydbinstall to this directory (don't want it thinking it is installing the working version)"
cp /Distrib/YottaDB/$gtm_verno/$tst_image/yottadb_r*/ydbinstall .

# --nopkg-config keeps these GT.M installs from rewriting /usr/share/pkgconfig/yottadb.pc, and
# --nolinkenv/--nolinkexec keep them from creating links in /usr/local/etc and /usr/local/bin; the sudo
# test saves and restores those around the whole run anyway, but there is no reason to disturb them here.
# Leaving pkg-config alone also keeps a line that varies by run order out of the output below. Capture each
# install to its own log so the output is uniform and the version can be pulled back out of it.
set instopts = "--gtm --nolinkenv --nolinkexec --nopkg-config $installoptions"

echo ""
echo "# Install V7.2-000, which lives in the new SourceForge folder. This is the case YDB#1242 reported."
$sudostr ./ydbinstall $instopts --installdir $PWD/V7.2-000 V7.2-000 >& V7.2-000.log
cat V7.2-000.log

echo ""
echo "# Install V7.1-011, from the original SourceForge folder, to check that fallback still works"
$sudostr ./ydbinstall $instopts --installdir $PWD/V7.1-011 V7.1-011 >& V7.1-011.log
cat V7.1-011.log

echo ""
echo "# Install the latest GT.M version, i.e. no version on the command line"
$sudostr ./ydbinstall $instopts --installdir $PWD/latest >& latest.log
cat latest.log

# Which version is latest changes every time FIS makes a release, so assert a property that stays true
# instead of putting the version itself in the reference file: it has to be at least V7.2-000. Before the
# fix this resolved to V7.1-011 and would have stayed there no matter what FIS released afterwards. Do the
# comparison in M with the test system's own mumps -- run here, before the environment is repointed at the
# GT.M installs below, so $ydb_routines/$ydb_dist still resolve %XCMD. Comparing the major and minor
# numbers separately keeps a future V10.x from being judged older than V7.2-000 by a string compare.
# In the $select, maj=7 does NOT fall to the maj<7 "NO": both maj>7 and maj<7 are false, so it falls
# through to the min>1 clause that consults the minor number. That is deliberate -- it is a "> V7.1"
# threshold, so 7.0 and 7.1 are "NO" while 7.2+ are "YES". Writing maj>=7:"YES" would be wrong here: it
# would wrongly pass V7.0 and V7.1.
set latestver = `$tst_awk '/installed successfully/ {print $3}' latest.log`
$gtm_dist/mumps -run %XCMD 'set v="'"$latestver"'",maj=$piece($piece(v,"V",2),"."),min=$piece($piece(v,".",2),"-") write "# Is the latest GT.M version ydbinstall found at least V7.2-000 : ",$select(maj>7:"YES",maj<7:"NO",min>1:"YES",1:"NO"),!'

echo ""
echo "# The 'installed successfully' messages above only echo back the version that was asked for, so ask"
echo "# each install what it actually is. This is what catches fetching the wrong tarball, as opposed to"
echo "# fetching no tarball at all."
# Point gtmroutines at the install's own libgtmutil.so so that %XCMD (which lives there) can be
# zlinked; unset ydb_routines/ydb_dist so nothing from the test environment's YottaDB leaks in. Force
# gtm_chset="M" so that, when the test system randomizes into UTF-8 mode, GT.M does not try to load
# ICU (libicuio.so) whose version varies by machine; all we care about here is $ZVERSION. The "latest"
# install's $ZVERSION is asked for too, but masked in the reference file with ##TEST_AWK because which
# version it resolves to changes as FIS makes releases.
unsetenv ydb_routines
unsetenv ydb_dist
setenv gtm_chset "M"
foreach dir ("V7.2-000" "V7.1-011" "latest")
	setenv gtm_dist $PWD/$dir
	setenv gtmroutines "$gtm_dist/libgtmutil.so"
	$gtm_dist/mumps -run %XCMD 'zwrite $zversion'
end

# clean up the install directories since the files are owned by root and can't be gzipped by the test system
foreach dir ("V7.2-000" "V7.1-011" "latest")
	$sudostr rm -rf $PWD/$dir
end
