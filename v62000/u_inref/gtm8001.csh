#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8001 - test that ^%LCLCOL does not complain when a set causes no change
#
source $gtm_tst/com/cre_coll_sl.csh polish 1
$gtm_dist/mumps -run gtm8001
