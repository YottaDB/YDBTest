#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script is used by gtm8137.m to verify CRITSEMFAIL exists in the jobbed off children's output

set timeout = 30
while ($timeout)
    @ timeout--
    sleep 1
    $grep -q CRITSEMFAIL errorchild.erx*
    if (0 == $status) break
end
if (0 == $timeout) then
    echo "TEST-E-FAIL CRITSEMFAIL did not show up"
    exit 1
endif
