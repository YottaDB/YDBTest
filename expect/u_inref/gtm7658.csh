#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
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
cp $gtm_tst/$tst/u_inref/gtm7658d.ro .
expect >& gtm7658.out <<\eof	# send the output to a file because expect may pollute it with control characters
set timeout 120
spawn /usr/local/bin/tcsh -f
expect "*>"
send -- "set prompt=\"termmumps > \"\r"
expect "*set prompt=\"termmumps > \""
expect "termmumps >"
send -- "\$gtm_dist/mumps -direct\r"
expect "YDB>"
send -- "use \$principal:(cenable:ctrap=\$char(4):exception=\"write !,\$zstatus\")\r"
expect "YDB>"
send -- "zshow \"d\":b\r"
expect "YDB>"
send -- "do ^%RI\r"
expect "Formfeed delimited <No>? "
send -- "\r"
expect "Input device: <terminal>: "
send -- "^\r"
expect "YDB>"
send -- "do ^%RI\r"
expect "Formfeed delimited <No>? "
send -- "\r"
expect "Input device: <terminal>: "
send -- "\003"
expect "YDB>"
send -- "do ^%RI\r"
expect "Formfeed delimited <No>? "
send -- "\003"
expect "YDB>"
send -- "do ^%RI\r"
expect "Formfeed delimited <No>? "
send -- "\r"
expect "Input device: <terminal>: "
send -- "gtm7658d.ro\r"
expect "Output directory : "
send -- "\r"
expect "YDB>"
send -- "zshow \"d\":a\r"
expect "YDB>"
send -- "write \$select(\$piece(a(\"D\",1),\" \",2,99)=\$piece(b(\"D\",1),\" \",2,99):\$char(80,65,83,83),1:\$char(70,65,73,76)),\" from gtm7658\"\r"
expect "YDB>"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
\eof
$grep PASS gtm7658.out		# just look for the pass to avoid dealing with things expect may insert on some platforms
