#################################################################
#								#
# Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# uni_max_strlen.csh
#
$switch_chset "UTF-8"
set dir1 = "multi_ｂｙｔｅ_後漢書_𠞉𠟠_4byte"
\mkdir $dir1
cd $dir1
setenv GTMCI cmm.tab
cat >> $GTMCI << aa
unimaxstr: void  munimaxstr^munimaxstr(I:gtm_char_t*,I:gtm_char_t*)
aa
#
$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/cunimaxstrlen.c -I$gtm_dist >& compiler.outx
if($status) then
	echo "TEST-E-COMPILE erros. check compiler.outx"
endif
$gt_ld_linker $gt_ld_option_output unimaxstrlen $gt_ld_options_common cunimaxstrlen.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map
if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
# run unimaxstrlen
unimaxstrlen
#
# Run unimaxstrlen again to specifically re-create an issue that can occur in V60003 when configured as follows:
#   - $gtmdbglvl=0x30
#   - $gtm_custom_errors undefined
#
# Note it is possible that the above choices are already part of this run (they are both possible random test system
# values), this particular combination seems rather rare so force it always.
#
#
$echoline
echo "#"
echo '# Specific test with $gtmdbglvl=0x30 and $gtm_custom_errors undefined'
echo "#"
if ($?gtmdbglvl) then
    set gtmdbglvl_save_umsl = $gtmdbglvl
endif
setenv gtmdbglvl 0x30
if ($?gtm_custom_errors) then
    set gtm_custom_errors_save_umsl = $gtm_custom_errors
endif
unsetenv gtm_custom_errors
unimaxstrlen
if ($?gtmdbglvl_save_umsl) then
    setenv gtmdbglvl $gtmdbglvl_save_umsl
else
    unsetenv gtmdbglvl
endif
if ($?gtm_custom_errors_save_umsl) then
    setenv gtm_custom_errors $gtm_custom_errors_save_umsl
endif
#
cd ..
unsetenv GTMCI

