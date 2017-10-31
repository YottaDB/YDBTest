#################################################################
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
#	make_callin.csh - setup for testing env var in shlib path
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_timers.c
$gt_ld_shl_linker ${gt_ld_option_output}libtimers${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_timers.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_timers.tab
setenv  my_shlib_path `pwd`
echo '$my_shlib_path'"/libtimers${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
timers^init:	void	init_timers()   These words should be ignored
timers^tstslp:	void	tst_sleep(I:xc_long_t)
timers^tsttmr:	void	tst_timer(I:xc_long_t, I:xc_long_t)
xx
