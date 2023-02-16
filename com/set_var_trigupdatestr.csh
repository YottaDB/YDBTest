#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This is a helper script that sets the variable "trigupdatestr" to point to "" or "-trigupdate" so a caller script
# can then determine if a "mupip replic -source -start" (caller script "com/SRC.csh") or "mupip replic -source -activate"
# (caller script "com/activate_source.csh") needs to add "$trigupdatestr" also to its command line.

set trigupdatestr = ""
set ver = $gtm_exe:h:t
if (`expr "$ver" ">" "V63014_R136"`) then
	# For YottaDB versions greater than r1.36, -trigupdate is supported. So add it if the env var is randomly set.
	if ($?gtm_test_trigupdate) then
		if ($gtm_test_trigupdate) then
			set trigupdatestr = "-trigupdate"
		endif
	endif
endif

