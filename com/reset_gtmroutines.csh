#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
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
# This script is mainly meant for MSR actions and replication in general. It will be called "getenv" scripts before executing respective replication action
# In addition to switch_gtm_versions.csh where gtmroutines is handled for prior version switch this script will also set gtmroutines appropriate
# Because MSR world operates differently. It sets up the environment in its own self sufficient way based on the msr_configurations and such.
# However they all execute "getenv" scripts where before the final replication action on any given site the env. is setup.
# reset_gtmroutines will be called by those "getenv" scripts and correct translatation of gtmroutines as per the version and the chset mode is done
#
set chset = "M"
if (51 < "`echo $gtm_exe:h:t|cut -c2-3`") then
	if ($?gtm_chset) then
		if ("UTF-8" == "$gtm_chset") then
			set chset = "UTF8"
		endif
endif
source $gtm_tst/com/set_gtmroutines.csh $chset

