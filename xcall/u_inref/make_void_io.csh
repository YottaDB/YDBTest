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
#	make__void_io.csh - setup for void functions taking input/output arguments.
#       This table maps all the gtm types as defined in $gtm_dist/gtmxc_types.h
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_io.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_io${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_io.o $gt_ld_syslibs 
setenv	GTMXC	gtmxc_void_io.tab
echo "`pwd`/libvoid_io${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void	gtm_void()
iolongp:	void	gtm_iolongp(IO:gtm_long_t *)
ioulongp:	void	gtm_ioulongp(IO:gtm_ulong_t *)
iofloatp:	void	gtm_iofloatp(IO:gtm_float_t *)
iodoublep:	void	gtm_iodoublep(IO:gtm_double_t *)
iocharpp:	void	gtm_iocharpp(IO:gtm_char_t **)
iostringp:	void	gtm_iostringp(IO:gtm_string_t *)
iostringp2:	void	gtm_iostringp2(IO:gtm_string_t *)
iointp:	        void	gtm_iointp(IO:gtm_int_t *)
iouintp:	void	gtm_iouintp(IO:gtm_uint_t *)
xx
