#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
#
# cre_coll_sl_all.csh
#
# This script builds all alternative collation sequences
# needed by the test system
#
source $gtm_tst/com/cre_coll_sl.csh com/col_straight.c 1
source $gtm_tst/com/cre_coll_sl.csh com/col_reverse.c 2
source $gtm_tst/com/cre_coll_sl.csh com/col_polish.c 3
source $gtm_tst/com/cre_coll_sl.csh com/col_polish_rev.c 4
source $gtm_tst/com/cre_coll_sl.csh com/col_chinese.c 5
source $gtm_tst/com/cre_coll_sl.csh com/col_complex.c 6
