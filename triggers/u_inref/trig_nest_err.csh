#!/usr/local/bin/tcsh -f
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
#  trig_nesterr_err.csh - nested calls - M1 -> C -> M2, M2 with errors, $ET, $ZT default values
#

$gtm_tst/com/dbcreate.csh mumps 1

# load trigger
cat > trig_nest_err.trg << TFILE
+^a -command=S -xecute="do ^trignsterror"
TFILE

$MUPIP trigger -triggerfile=trig_nest_err.trg
echo "" | $MUPIP trigger -select

$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/trig_nesterr.c
$gt_ld_shl_linker ${gt_ld_option_output}libtrig_nesterr${gt_ld_shl_suffix} $gt_ld_shl_options trig_nesterr.o $gt_ld_syslibs $tst_ld_sidedeck >&! link1.map 

if( $status != 0 ) then
    cat link1.map
endif

rm -f link1.map
rm -f trig_nesterr.o
#
# external call
#
setenv	GTMXC	mtoc.tab
echo "`pwd`/libtrig_nesterr${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
inmult:		void	xc_inmult(I:xc_float_t *, I:xc_double_t *, I:xc_char_t *, I:xc_char_t **, I:xc_string_t *)
xx
#
# call_in
# 
setenv GTMCI ctom.tab
cat >> $GTMCI << yy
dtrignsterror:  void ^trignsterror()
yy
unsetenv $GTMCI
#
#
$GTM <<EOF
Write "set ^a to trigger trignsterror",!
set ^a=1
Halt
EOF
unsetenv GTMXC
$gtm_tst/com/dbcheck.csh
