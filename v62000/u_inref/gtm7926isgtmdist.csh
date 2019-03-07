#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# This test exists to verify that MUMPS/MUPIP/DSE/LKE can validate that they
# reside in $gtm_dist.
#

#
# MUMPS dlopen()s $gtm_dist/libyottadb.so which in effect validates $gtm_dist.
# It uses $gtm_dist for help, the JOB command, as a search path for pipe
# devices, and to call gtmsecshr.
#
# MUMPS call-ins work differently, see gtm7926callins for more information.
#
# MUPIP relies on $gtm_dist directly for help and for starting the
# Update/Helper Process (tested in gtm7926rcvr) and for calling gtmsecshr.
#
# LKE relies on $gtm_dist when calling help.
#
# DSE relies on $gtm_dist for help and for calling gtmsecshr.
#
# MUMPS/MUPIP/DSE/LKE all implicitly rely on $gtm_dist/plugin/libgtmcrypt.so when
# using encryption. If $gtm_dist is not ok to use then encryption initilization
# will fail. LKE only opens the database for LKE SHOW
#
# The GT.CM OMI server relies on $gtm_dist directly when processing error
# messages (tested in v54002/C9K08003311).
#

#
# The tests below use the helper script test/v62000/inref_u/gethelp.csh to
# drive the HELP function for MUPIP, DSE, and LKE. Depending on the execution,
# we expect the executable to pass in most scenarios.
#

$gtm_tst/com/dbcreate.csh mumps 1

@ testno=0
set ENVdist=$gtm_dist
set exedist=$gtm_dist
echo "Testing that we can use the existing gtm_dist (${ENVdist}) directory structure"
foreach exe (dse mupip lke)
	foreach idir ( "" /utf8 )
		$gtm_tst/$tst/inref/gethelp.csh ${exedist}${idir}/${exe} ${testno} ${ENVdist}
	end
end

@ testno++
ln -s $gtm_dist mydist
set ENVdist=`$gtm_dist/mumps -run chooseamong $gtm_dist ./mydist`
set exedist=./mydist
echo "Testing that we can use a symlink to gtm_dist and either the existing gtm_dist ($gtm_dist) or the symlink"
foreach exe (dse mupip lke)
	foreach idir ( "" /utf8 )
		$gtm_tst/$tst/inref/gethelp.csh ${exedist}${idir}/${exe} ${testno} ${ENVdist}
	end
end

@ testno++
set ENVdist=$gtm_dist
set exedist=aliasbin
mkdir -p ${exedist}/utf8
echo "Testing that we can use symlinked executables and retain the existing dollar gtm_dist (${ENVdist})"
foreach exe (dse mupip lke)
	foreach idir ( "" /utf8 )
		ln -s $gtm_dist/${exe} ${exedist}${idir}/${exe}
		$gtm_tst/$tst/inref/gethelp.csh ${exedist}${idir}/${exe} ${testno} ${ENVdist}
	end
end


@ testno++
set origpath=($path)
set ENVdist=$gtm_dist
set exedist=$gtm_dist
echo "Testing that we can use executables from PATH and retain the existing dollar gtm_dist (${ENVdist})"
foreach idir ( "" /utf8 )
	set path=($origpath ${exedist}$idir)
	foreach exe (\dse \mupip \lke)
		$gtm_tst/$tst/inref/gethelp.csh ${exe} ${testno} ${ENVdist}
	end
end

@ testno++
echo "$gtm_curpro" > priorver.txt
set ENVdist=$gtm_root/$gtm_curpro/pro
set exedist=$gtm_dist
echo "Testing that we cannot use executables from PATH which don't reside in the supplied dollar gtm_dist (${ENVdist})"
foreach idir ( "" /utf8 )
	set path=($origpath ${exedist}$idir)
	foreach exe (\dse \mupip \lke)
		$gtm_tst/$tst/inref/gethelp.csh ${exe} ${testno} ${ENVdist}
	end
end
set path=($origpath)

@ testno++
set ENVdist=$gtm_root/$gtm_curpro/pro
set exedist=$gtm_dist
echo "Testing that we cannot supply a dollar gtm_dist (${ENVdist}) that is different from the executables path (${exedist})"
foreach exe (dse mupip lke)
	foreach idir ( "" /utf8 )
		$gtm_tst/$tst/inref/gethelp.csh ${exedist}${idir}/${exe} ${testno} ${ENVdist}
	end
end

$gtm_tst/com/dbcheck.csh
