#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test MIXIMAGE error is appropriately issued when multiple images are mixed in same process
#
# First create simple call-in
#
setenv GTMCI environci.xc
cat >> $GTMCI << EOF
miximagecallin: void ^miximagecallin()
EOF
#
# Build base C executable that in turn invokes the call-in (and a different image to in turn trigger MIXIMAGE error)
#
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_dist $gtm_tst/$tst/u_inref/miximage.c
$gt_ld_shl_linker ${gt_ld_option_output} miximage miximage.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_gtmshr $gt_ld_syslibs >& link.map
if (0 != $status) then
	cat link.map
endif
#
# Now for each function corresponding to a base-image and that is exported in libgtmshr.so, try invoking that function
# from the same C process that also opened libgtmshr.so (through the above call-in invocation). We expect a MIXIMAGE
# error for each of those invocations. Do it in a loop.
foreach func (dbcertify_main dse_main ftok_main mupip_main lke_main gtcm_play_main gtcm_server_main gtcm_shmclean_main gtcm_gnp_server_main)
	echo "  --> Expecting MIXIMAGE error for $func"
	./miximage $func
	echo ""
end
