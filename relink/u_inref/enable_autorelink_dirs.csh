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

# This script enables autorelink on all directories in $gtmroutines.

set gtm_test_autorelink_dirs = 1
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) then
		source $gtm_tst/com/set_gtmroutines.csh "UTF8"
	else
		source $gtm_tst/com/set_gtmroutines.csh "M"
	endif
else
	# If gtm_chset is not set, gtmroutines should point to the M objects/sources and not UTF-8.
	source $gtm_tst/com/set_gtmroutines.csh "M"
endif
