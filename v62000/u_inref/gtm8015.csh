#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2014 Fidelity Information Services, Inc		#
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cp $gtm_tst/$tst/inref/gtm8015.m ./
foreach bool (-1 0 1 2 3)
	foreach side_effect (-1 0 1 2 3)
		$echoline
		echo "Testing with gtm_boolean=$bool & gtm_side_effects=$side_effect"
		setenv gtm_boolean $bool
		setenv gtm_side_effects $side_effect
		$gtm_dist/mumps gtm8015.m
		$gtm_dist/mumps -run gtm8015
	end
end
