#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##getenv.csh
#
###############################
## YDB software environments ##
###############################
setenv gtm_ver_noecho
if ("GT.CM" == "$test_gtm_gtcm") then
	set hostn = $HOST:r:r:r
	#set ver = `echo "" | $tst_awk '{system("echo $remote_ver_gtcm_'$hostn'")}'`
	set ver = `setenv | $grep "^remote_ver_gtcm_$hostn=" | cut -d= -f2`
	#set ima = `echo "" | $tst_awk '{system("echo $remote_image_gtcm_'$hostn'")}'`
	set ima = `setenv | $grep "^remote_ima_gtcm_$hostn=" | cut -d= -f2`
	if ("" == "$ver") set ver = $remote_ver
	if ("" == "$ima") set ima = $remote_image
	source $gtm_tst/com/set_active_version.csh $ver $ima
else
	source $gtm_tst/com/set_active_version.csh $remote_ver $remote_image
endif
setenv YDB "$gtm_exe/mumps -direct"
setenv GTM "$gtm_exe/mumps -direct"
setenv MUPIP "$gtm_exe/mupip"
setenv LKE "$gtm_exe/lke"
setenv DSE "$gtm_exe/dse"
setenv GDE "$gtm_exe/mumps -run GDE"
# gtm_chset will be randomly chosen to either UTF-8 or M and so we need to set the proper locale
# and gtmroutines as a part of env. setup.
source $gtm_tst/com/set_locale.csh
source $gtm_tst/com/set_ldlibpath.csh
source $gtm_tst/com/reset_gtmroutines.csh
