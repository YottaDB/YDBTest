#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# 0 exit status indicates the need to turn off UTF-8 mode for prior versions
# 1 exit status indicates that the test can stay in UTF-8 mode

if ($?gtm_icu_version) then
	if (`expr $gtm_tst_icu_numeric_version ">=" 44`) then
		exit 0
	endif
else
	# (implemented for sphere) AIX 7's stock ICU libraries have symbol renaming
	# disabled and are accessible, as libicuio.a(libicuio.so), and therefore usable by
	# GT.M. However, versions V53004 to V54000A core dump due to the inclusion of
	# thread libraries. sphere is not configured with older ICU libraries AND
	# $cms_tools/is_icu_symbol_rename.csh returns that ICU version need not be set on
	# sphere. strato, currently AIX 7, has ICU 3.6 libraries built with symbols renamed
	if (("HOST_AIX_RS6000" == $gtm_test_os_machtype) && (6 < $gtm_test_osver)) then
		exit 0
	endif
endif

exit 1
