#################################################################
#								#
# Copyright 2003, 2014 Fidelity Information Services, Inc	#
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
#
# c_args.csh
#
source $gtm_tst/com/dbcreate.csh mumps 3
if (0 == $?test_replic) then
	$gtm_exe/mupip set $tst_jnl_str -reg "*" >&! jnl_on.log
	$grep "GTM-I-JNLSTATE" jnl_on.log |& sort -f
endif

setenv GTMCI args1.tab
cat >> $GTMCI << args1tab
build:  void ^bldrecs()
getcode: char* ccode^getrec2(I:long)
get_int: void int^getrec2(I:long,O:float*,O:float*)
get_bal: double* extbal^getrec2(I:long)
putrec: void savact^putrec(I:long,I:double,I:float,I:float)
args1tab
#
#

$gt_cc_compiler $gtt_cc_shl_options $gtm_tst/$tst/inref/ci_args.c -I$gtm_dist
$gt_ld_linker $gt_ld_option_output ciargs $gt_ld_options_common ci_args.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
ciargs
unsetenv $GTMCI
if (1 == $gtm_test_trigger) then
	# Since same triggers can be loaded in multiple regions, ignore the runtime disambiguator and count
	# i.e all of the below are counted as the same trigger "ACCT"
	# ^fired("ACCT#2#","S")=9
	# ^fired("ACCT#2#A","S")=5
	# ^fired("ACCT#2#B","S")=21
	$gtm_exe/mumps -run %XCMD 's s="" f  s s=$o(^fired(s),1) zwrite:s="" firedtrig q:s=""  set firedtrig($piece(s,"#",1))=$get(firedtrig($piece(s,"#",1)))+^fired(s,"S")'
endif
$gtm_tst/com/dbcheck.csh -extract






