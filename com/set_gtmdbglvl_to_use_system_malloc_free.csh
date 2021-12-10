#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script is the inverse of "$gtm_tst/com/set_gtmdbglvl_to_use_yottadb_malloc_free.csh"

# Set env var that will ensure we use system malloc/free (and not the YottaDB malloc/free).
setenv gtmdbglvl 0x80000000

# Note that if the caller had set gtmdbglvl to a non-zero value, this script does not currently
# add the 31st bit (that ensures we use system malloc/free) to the existing value.
# Instead it overwrites the entire env var value to be a value where just the 31st bit is set.
# This limitation will be fixed in the future when a need for that addition arises.

