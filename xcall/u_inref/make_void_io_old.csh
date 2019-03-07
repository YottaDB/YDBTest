#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#	make_void_io_old.csh - setup for void functions taking input/output arguments.
#
#	This is the same as make_void_io.csh except that it declares the function
#	argument types using deprecated xc form of the types 
#	defined in $gtm_dist/gtmxc_types.h.
#	This is to test that we still support the undocumented types we used to
#	support in earlier releases of the Unix external call mechanism for
#	backward compatibility with old releases sent to Sanchez Computer
#	Associates (SCA).
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmxc_void_io.c
$gt_ld_shl_linker ${gt_ld_option_output}libvoid_io_o${gt_ld_shl_suffix} $gt_ld_shl_options gtmxc_void_io.o $gt_ld_syslibs 

setenv	GTMXC	gtmxc_void_io.tab
echo "`pwd`/libvoid_io_o${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
void:		void	xc_void()
iolongp:	void	xc_iolongp(IO:xc_long_t *)
ioulongp:	void	xc_ioulongp(IO:xc_ulong_t *)
iofloatp:	void	xc_iofloatp(IO:xc_float_t *)
iodoublep:	void	xc_iodoublep(IO:xc_double_t *)
iocharpp:	void	xc_iocharpp(IO:xc_char_t **)
iostringp:	void	xc_iostringp(IO:xc_string_t *)
iostringp2:	void	xc_iostringp2(IO:xc_string_t *)
iointp:	        void	xc_iointp(IO:xc_int_t *)
iouintp:	void	xc_iouintp(IO:xc_uint_t *)
xx
