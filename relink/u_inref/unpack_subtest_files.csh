#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Copy inref files into working directory and strip "subtestname-" prefix.
# This is useful if we have two subtests that want to use the same routine name, say a.m,
# but subtest1-a.m and subtest2-a.m are different.
#
# Also, in the relink test suite, the convention is to append some source files with ".edit{1,2,3..}".
# These files are stored in $gtm_tst with an additional ".m" extension, so while unpacking, go ahead
# and strip trailing ".m" from filename.edit*.m
#
# see: test/java/u_inref/unpack_java_src.csh
#

set subtest = $1
set dir = $2
foreach src ( $gtm_tst/$tst/inref/$subtest-* )
	set dst = ${src:t}					# remove path
	set dst = ${dst:as;-;/;}
	set dst = ${dst:t}					# remove path (i.e subtest prefix)
	# strip trailing ".m" from filename.edit*.m
	set a = ${dst:e}					# extension
	set strip = ${dst:r}
	set b = ${strip:e}					# second extension (e.g. "edit" in file.edit.m)
	if ( ($a == "m") && ($b =~ "edit*") ) set dst = $strip	# remove extension
	mkdir -p $dir
	cp $src $dir/$dst
end
