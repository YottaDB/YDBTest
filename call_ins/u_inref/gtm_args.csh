#################################################################
#								#
# Copyright 2003, 2014 Fidelity Information Services, Inc	#
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
# gtm_args.csh
#
source $gtm_tst/com/dbcreate.csh mumps 7
setenv GTMCI args1.tab
cat >> $GTMCI << args1tab
build:  void ^build()
main:   void ^main()
getcode: gtm_char_t* ccode^getrec2(I:gtm_long_t)
get_int: void int^getrec2(I:gtm_ulong_t,O:gtm_float_t*,O:gtm_float_t*)
get_bal: gtm_double_t* extbal^getrec2(I:gtm_long_t)
putrec: void savact^putrec(I:gtm_long_t,I:gtm_double_t,I:gtm_float_t,I:gtm_float_t)
change_int: void chgint^getrec2(I:gtm_long_t,IO:gtm_float_t*)
args1tab
#
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/gtmci_args.c
$gt_ld_linker $gt_ld_option_output args $gt_ld_options_common gtmci_args.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& link.map

if( $status != 0 ) then
    cat link.map
endif
rm -f  link.map
#
args
unsetenv GTMCI
if (1 == $gtm_test_trigger) then
	# Since same triggers can be loaded in multiple regions, ignore the runtime disambiguator and count
	# i.e all of the below are counted as the same trigger "ACCT"
	# ^fired("ACCT#2#","S")=9
	# ^fired("ACCT#2#A","S")=5
	# ^fired("ACCT#2#B","S")=21
	$gtm_exe/mumps -run %XCMD 's s="" f  s s=$o(^fired(s),1) zwrite:s="" firedtrig q:s=""  set firedtrig($piece(s,"#",1))=$get(firedtrig($piece(s,"#",1)))+^fired(s,"S")'
endif
$gtm_tst/com/dbcheck.csh -extract


