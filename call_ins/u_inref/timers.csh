#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

######################################################################################
# Test gtm_start_timer() and gtm_cancel_timer() functionality from within a call-in, #
# also ensuring that scheduling a timer with non-positive expiration range does      #
# not result in an error.                                                            #
######################################################################################

# Set GTMCI; since we are not calling M functions, keep it empty.
setenv GTMCI timers.tab
touch $GTMCI

# Compile and link timers.c.
$gt_cc_compiler $gt_cc_options_common $gtm_tst/$tst/inref/timers.c -I$gtm_dist -g -DDEBUG
$gt_ld_linker $gt_ld_option_output timers $gt_ld_options_common timers.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if ($status) then
	echo "Linking failed:"
	cat link.map
endif
rm -f link.map

# Invoke the executable
timers

# Unset GTMCI.
unsetenv $GTMCI
