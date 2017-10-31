#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright 2011, 2014 Fidelity Information Services, Inc	#
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

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gt_cc_option_I -I$gtm_tst/$tst/inref $gtm_tst/$tst/inref/gtm6994co.c
$gt_ld_shl_linker ${gt_ld_option_output}libgtm6994co${gt_ld_shl_suffix} $gt_ld_shl_options gtm6994co.o $gt_ld_syslibs >&! link1.map

if( $status != 0 ) then
    cat link1.map
endif
rm -f link1.map

setenv  GTMXC   gtm6994co.tab
echo "`pwd`/libgtm6994co${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << ENDXC
longtestcount:	gtm_int_t	longtestcount()
retlong:	gtm_long_t	retlong(I:gtm_int_t)
longptrout:	gtm_status_t	longptrout(I:gtm_int_t, O:gtm_long_t*)
ulongtestcount:	gtm_int_t	ulongtestcount(I:gtm_int_t)
retulong:	gtm_ulong_t	retulong(I:gtm_int_t)
ulongptrout:	gtm_status_t	ulongptrout(I:gtm_int_t, O:gtm_ulong_t*)
nestxcall:	gtm_int_t	nestxcall(I:gtm_int_t,I:gtm_int_t)
ENDXC

$GTM <<ENDGTM
write !,"callout tests",!
do callout^gtm6994
halt
ENDGTM

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/gtm6994ci.c -I$gtm_dist $gt_cc_option_I -I$gtm_tst/$tst/inref
$gt_ld_linker $gt_ld_option_output gtm6994ci $gt_ld_options_common gtm6994ci.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >&! link2.map

if( $status != 0 ) then
    cat link2.map
endif
rm -f link2.map

setenv GTMCI gtm6994ci.tab
cat > $GTMCI << ENDCI
callin_long:		void		callin^gtm6994(I:gtm_long_t)
callin_longptr:		void		callin^gtm6994(I:gtm_long_t*)
callin_ulong:		void		callin^gtm6994(I:gtm_ulong_t)
callin_ulongptr:	void		callin^gtm6994(I:gtm_ulong_t*)
callin_nestxcall:	gtm_int_t*	nestcallin^gtm6994(I:gtm_int_t,I:gtm_int_t)
ENDCI

gtm6994ci

echo "# Test of nested call-ins where call-in has a return value"
echo "# Below function basically does 1+2+3+...+100 = 5050 and prints it."
$GTM <<\ENDGTM
set depth=0
for i=1:10:100 set depth=depth+$$nestcallin^gtm6994(i,i+10)
write "1+2+3+...100 = ",depth,!
\ENDGTM

