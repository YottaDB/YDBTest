#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Test that if caller_id() stub is used the 'generated from' address is 0xFFFFFFFF

@ section = 0
set echoline = "echo ---------------------------------------------------------------------------------------"

alias BEGIN "source $gtm_tst/com/BEGIN.csh"
alias END "source $gtm_tst/com/END.csh"

BEGIN "create database"
$GDE exit
$MUPIP create
END

BEGIN "create global and crash the database"
$GTM <<EOF
set ^x=1
zsy "$kill9 "_\$j
EOF
END

BEGIN "Do mupip rundown and check if the 0xFFFFFFFF is sent as <generated from> address to operator log"
set syslog_before = `date +"%b %e %H:%M:%S"`
$MUPIP rundown -region "*" >&! rundown.txt
$gtm_tst/com/getoper.csh "$syslog_before" "" "syslog.txt" "" "GTM-I-SEMREMOVED"

if (  $status == 0 ) then
	$grep "0xFFFFFFFF" syslog.txt >&! greplog.txt
	if (  $status == 0 ) then
		echo "0xFFFFFFFF is printed properly in operator log"
	endif
endif
END
