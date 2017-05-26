#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Prints the instance name corresponding to the instance file $gtm_repl_instance
#
$MUPIP replic -editinstance -show $gtm_repl_instance |& $tst_awk '/HDR Instance Name/ {print $NF}'
