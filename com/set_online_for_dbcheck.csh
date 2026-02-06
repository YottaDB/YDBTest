#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2005-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#!/usr/local/bin/tcsh -f

setenv online_noonline ""
# Environment variable  will be either set in the environment or set randomly by do_random_settings.csh
if ($?gtm_test_online_integ) then
	setenv online_noonline "$gtm_test_online_integ"
endif

#--------------------------------------------------------------------------------------
# Check if -online or -noonline was specified in the arguments. If so override randomly
# chosen value in do_random_settings.csh
# -------------------------------------------------------------------------------------
setenv online_noonline_specified "FALSE"
foreach arg ($argv)
	switch ($arg)
		case "-online":
			setenv online_noonline "-online"
			setenv online_noonline_specified "TRUE"
			breaksw
		case "-noonline":
			setenv online_noonline "-noonline"
			setenv online_noonline_specified "TRUE"
			breaksw
		default:
			setenv online_noonline ""
			breaksw
	endsw
	if ("TRUE" == "$online_noonline_specified") break
end

if (-e settings.csh) then
	set now=`date +%H%M%S`
	$grep gtm_test_db_format settings.csh >&! tmp_$now.csh
	source tmp_$now.csh
	\rm tmp_$now.csh
endif

# It is an error if the calling script wanted to do an INTEG -FILE but also has passed -[NO]ONLINE along with it
if (("$1" != "-online") && ("$1" != "-noonline") && ("TRUE" == "$online_noonline_specified")) then
	echo "TEST-E-DBCHECK: [NO]ONLINE qualifiers not supported INTEG -FILE"
	exit 1
endif
