#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Usage: $gtm_tst/com/mumps_curpro.csh [-utf8] [-cur_routines] (VARi=VALi ...) (MUMPSARGj ...)
#
# Runs the curpro version of mumps in a clean environment, with each environment variable VAR set to VAL,
# and MUMPSARGs on the mumps command line.
# Specifying -utf8 runs mumps in UTF-8 mode.
# Specifying -cur_routines pulls in routines from the current test version and current directory,
#				and places the associated objects in a curpro_obj subdirectory.
# Specifying -cur_dist_rtns pulls in routines from the current $gtm_dist and places the associated
# 				objects in a curpro_obj subdirectory. Assumes CHSET matches

while ("$argv[1]:s/-//" =~ {utf8,cur_routines,cur_dist_rtns})
	set opt_${argv[1]:s/-//}
	shift
end

set curprodir = "${gtm_root}/${gtm_curpro}/pro"
# If "pro" dir does not exist but "dbg" dir exists, use that instead
if (! -e $curprodir) then
	if (-e ${gtm_root}/${gtm_curpro}/dbg) then
		set curprodir = "${gtm_root}/${gtm_curpro}/dbg"
	endif
endif

set distdir = "${curprodir}"
if ($?opt_utf8) set distdir = "${curprodir}/utf8"

set rtns = "${curprodir}"
set testroutines = ""
set prevdist = ""
if ($?opt_cur_routines || $?opt_cur_dist_rtns) then
	set rtndir="./curpro_obj"
	# Use the current test version
	if ($?opt_cur_routines) set testroutines = "${0:h}"
	# Use the active GT.M version's routines. M sources are version specific, use a separate directory
	if ($?opt_cur_dist_rtns) then
		set prevdist = "${gtm_dist}"
		set rtndir="./curpro_obj_${gtm_verno}"
	endif
	# Override the use of curprodir as routines
	mkdir -p $rtndir
	set rtns = "$rtndir(${testroutines} ${prevdist:s/pro/dbg/} .) ${distdir}"
endif

set envargs = (	TERM=dumb				\
		gtm_dist="${distdir}"			\
		gtmroutines="${rtns}"			\
		)

if ($?opt_utf8) then
	# depending on the list of locales configured, locale -a might be considered a binary output. (on scylla currently)
	# grep needs -a option to process the output as text to get the actual value instead of "Binary file (standard input) matches"
	# but -a is not supported on the non-linux servers we have.
	if ("Linux" == "$HOSTOS") then
		set binaryopt = "-a"
	else
		set binaryopt = ""
	endif
	set envargs = ($envargs:q "gtm_chset=UTF-8" "LC_ALL=`locale -a | $grep $binaryopt -i utf | $grep -i en| $grep -i us`")
endif

# Most Unix servers require TZ settings for the correct localtime
if ($?TZ) then
	set envargs = ($envargs:q "TZ=$TZ")
endif

while (($#argv > 0) && ("$argv[1]" =~ *=*))
	set envargs = ($envargs:q "$argv[1]")
	shift
end

exec /usr/bin/env -i ${envargs:q} ${distdir}/mumps ${argv:q}
