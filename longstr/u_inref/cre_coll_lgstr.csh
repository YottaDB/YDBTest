#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Note that this is based on cre_coll_sl_reverse.csh under $gtmtst/com
# Create collation shared libraries for a "reverse" sequence ([1-255] -> [255-1])
# Two arguments, $1-> module path, 2-> sequence

# Local collation env var could be set to a broken .so file by a prior call to cre_coll_lgstr.csh.
# So unsetenv this to avoid errors in the "mumps -run %XCMD" call inside cre_coll_sl.csh.
# The previous call could have randomly set ydb_local_collate or gtm_local_collate. Not sure which one.
# So unsetenv both.
unsetenv ydb_local_collate gtm_local_collate

source $gtm_tst/com/cre_coll_sl.csh $1 $2
set save_gtm_collate = `setenv | grep "^gtm_collate_$2" | awk '{split($1,toks,"="); print toks[2]}'`
unsetenv ydb_collate_$2
unsetenv gtm_collate_$2
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_local_collate gtm_local_collate $2 # Randomly pick one to set
if ($?ydb_local_collate) then # Then set the same version of xxx_collate_$2.
	set col_n = "ydb_collate_$2"
else
	set col_n = "gtm_collate_$2"
endif
setenv $col_n $save_gtm_collate
