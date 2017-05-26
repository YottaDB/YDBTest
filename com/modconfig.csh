#!/usr/local/bin/tcsh
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
# Usage: modconfig.csh <config-file> <command> <arguments>
# See test/com_u/modconfig.c for more details.

if (! -x ./modconfig) then
	$gt_cc_compiler $gt_cc_options_common $gtm_tst/com/modconfig.c -I /usr/include -I /usr/local/include	>&! modconfig.compil
	$gt_ld_linker $gt_ld_option_output ./modconfig $gt_ld_options_common ./modconfig.o -L /usr/lib -L /usr/local/lib -lconfig \
														>&! modconfig.link
endif

./modconfig $*
set result = $status
rm -f modconfig.compil
rm -f modconfig.link
exit $result
