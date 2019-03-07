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
#
# some tests of ^%GI
#
$gtm_tst/com/dbcreate.csh mumps 1
cp $gtm_tst/$tst/inref/gtm8223a.go ./
expect >& gtm8223.out <<\eof	# send the output to a file because expect may pollute it with control characters
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
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "gtm8223a.go\r"
expect "OK <Yes>?"
send -- "^\r"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "gtm8223a.go\r"
expect "OK <Yes>?"
send -- "\003"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "^\r"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "\003"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "gtm8223a.go\r"
expect "OK <Yes>?"
send -- "\r"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "\r"
expect "Format <ZWR>?"
send -- "^\r"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "\r"
expect "Format <ZWR>?"
send -- "\003"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "\r"
expect "Format <ZWR>?"
send -- "g\r"
expect "> "
send -- "^x(\"hi\")\r"
expect "> "
send -- "sailor\r"
expect "> "
send -- "\004"
expect "YDB>"
send -- "do ^%GI\r"
expect "Input device: <terminal>:"
send -- "\r"
expect "Format <ZWR>?"
send -- "\r"
expect "> "
send -- "^z(2.134)=\"pi\"\r"
expect "> "
send -- "\003"
expect "YDB>"
send -- "zshow \"d\":a\r"
expect "YDB>"
send -- "write \$select(\$piece(a(\"D\",1),\" \",2,99)=\$piece(b(\"D\",1),\" \",2,99):\$char(80,65,83,83),1:\$char(70,65,73,76)),\" from gtm8223\"\r"
expect "YDB>"
send -- "halt\r"
expect "termmumps >"
send -- "exit\r"
expect eof
\eof
$grep PASS gtm8223.out		# just look for the pass to avoid dealing with things expect may insert on some platforms
$gtm_tst/com/dbcheck.csh
