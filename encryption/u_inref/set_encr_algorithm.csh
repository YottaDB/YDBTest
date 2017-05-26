#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Helper script for the iv_ops test to update the encr_algorithm variable.
if ("BLOWFISHCFB" == $encryption_algorithm) then
	setenv encr_algorithm bf-cfb
else if ("AES256CFB" == $encryption_algorithm) then
	setenv encr_algorithm aes-256-cfb
endif
echo $encr_algorithm >> algorithm.txt
