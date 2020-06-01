#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# If imptp.csh is started on a different host than the test was started on,
# (for example in msreplic_E/switch_over)
# then $tst_dir will be set to the absolute directory of the original host,
# not that of the current host.
#
# As a workaround, we look for the first parent directory titled $gtm_tst_out,
# starting with the current working directory.
# For example, given
# - $gtm_tst_out = tst_V999_R129_pro_01_200530_130231
# - $PWD = /extra5/testarea2/nars/tst_V999_R129_pro_01_200530_130231/msreplic_E_1/switch_over/instance2
# The expected output is /extra5/testarea2/nars/tst_V999_R129_pro_01_200530_130231
#
# $1 = $gtm_tst_out as set by gtmtest.csh
set gtm_tst_out = "$argv[1]"

while (`basename $PWD` != "$gtm_tst_out")
	cd ..
	if ("/" == "$PWD") then
		# We didn't find it. Not much we can do, but at least we can prevent an infinite loop.
		echo "$gtm_tst_out"
		exit 1
	endif
end

pwd -P
