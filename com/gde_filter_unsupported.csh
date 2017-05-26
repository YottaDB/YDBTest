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

# Triggers test copies the gde file created by the most recent version and feeds it to prior version.
# This becomes a problem when a new command parameter is added to the GDE. This script filters out
# the commands that are not supported by prior versions. This is called from dbcheck_base.csh.

set gdefile = $1
set priorver = $2

set filterexp = ""

# Do not forget to add | next before the new pattern.

if (`expr $priorver "<" "V62001"`) then
    # Filter out spanning region names
    set filterexp = "$filterexp|(add .name [a-z%A-Z][a-zA-Z0-9]*\(.*\) .region=.*)"
endif

if (`expr $priorver "<" "V62002"`) then
    set filterexp = "$filterexp|defer_allocate|epochtaper"
endif

# There is nothing to filter out. Do nothing.
if ("" == "$filterexp") exit 0

# Remove the first |
set filterexp = "$filterexp:s/|//"

mv ${gdefile} ${gdefile:r}_unsupported.gde
$grep -Evi "$filterexp" ${gdefile:r}_unsupported.gde > ${gdefile}
