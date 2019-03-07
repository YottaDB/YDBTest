#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Use VIEW "FLUSH" (and not VIEW "EPOCH") since the former is supported by older versions too
# and this script could be invoked by tests that use older versions.

$gtm_exe/mumps -run %XCMD 'view "FLUSH"'
