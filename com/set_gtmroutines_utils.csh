#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script is to temporarily reset gtmroutines to point to the utils directory

set envlist_to_modify = "gtmroutines"
set envlist_to_unset = "gtmdbglvl gtm_trace_gbl_name"
if ("restore" == "$1") then
	foreach var ($envlist_to_modify $envlist_to_unset)
		printenv tst_save_$var >&! /dev/null
		if (! $status) then
			setenv $var "`printenv tst_save_$var`"
			unsetenv tst_save_$var
		endif
	end
	exit
endif

if ($?gtm_chset) then
	set chsetdir = "$gtm_chset"
else
	set chsetdir = "M"
endif

if ( $PWD =~ "*$gtm_tst_out*" ) then
	set topdir = `echo $PWD | sed 's/'$gtm_tst_out'.*/'$gtm_tst_out'/'`
	set utilobjdir = "$topdir/utilobj/$gtm_verno/$chsetdir"
else
	# not in a proper test output directory. utilobj dir cannot be created. Exiting
	exit 1
endif


if (! -d $utilobjdir) then
	mkdir -p $utilobjdir
endif

setenv tst_save_gtmroutines "$gtmroutines"
setenv gtmroutines "$utilobjdir($gtm_tst/com) $tst_save_gtmroutines"

foreach var ($envlist_to_unset)
	printenv $var >&! /dev/null
	if (! $status) then
		setenv tst_save_$var "`printenv $var`"
		unsetenv $var
	endif
end
unset chsetdir topdir utilobjdir

