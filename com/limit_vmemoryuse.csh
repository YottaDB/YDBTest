#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
# $1 - vmemoryuse setting to use
#

# Tests that limit the "vmemoryuse" setting (virtual memory limit for a process) are sensitive to changes in
# the "stacksize" setting. For example, we have seen a "stacksize" setting of "32Mb" cause the subtests
# v63000/gtm8394, simpleapi/fatalerror1, simpleapi/fatalerror2, simplethreadapi/fatalerror1 and simplethreadapi/fatalerror2
# to fail. What we do know is that a "stacksize" setting of 8Mb enables those subtests to pass. So set the "stacksize"
# to the safe value whenever this script is called (callers are only one of the above affected subtests who do not care
# about the "stacksize" setting but do care about the "vmemoryuse" setting).
limit stacksize 8192 kbytes

limit vmemoryuse $1
