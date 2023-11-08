#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##############################################################################
# returns the number of seconds since the beginning of the year
# str has to be in the format: 2023-12-18T21:09:49.351907+00:00
# does not consider the year
# Sample messages
#2023-12-18T21:09:49.308606+00:00 3a77d12d712f YDB-MUMPS[16756]: 12-18-2023 21:09 /testarea1/tst_V999_R999_dbg_00_231218_210947/r132_0/ydb551 Wine#012#015
#2023-12-18T21:09:49.319597+00:00 3a77d12d712f YDB-MUMPS[16757]: 12-18-2023 21:09 /testarea1/tst_V999_R999_dbg_00_231218_210947/r132_0/ydb551 Beer!#012#015
#2023-12-18T21:09:49.330375+00:00 3a77d12d712f YDB-MUMPS[16758]: 12-18-2023 21:09 /testarea1/tst_V999_R999_dbg_00_231218_210947/r132_0/ydb551 Pizza!#012#015
#2023-12-18T21:09:49.341161+00:00 3a77d12d712f YDB-MUMPS[16759]: !AD 12-18-2023 21:09 /testarea1/tst_V999_R999_dbg_00_231218_210947/r132_0/ydb551
#2023-12-18T21:09:49.351907+00:00 3a77d12d712f YDB-MUMPS[16760]: 12-18-2023 21:09 /testarea1/tst_V999_R999_dbg_00_231218_210947/r132_0/ydb551 ZSYSLOGR
BEGIN {
	# Don't use scientific format in the output
	OFMT="%f";
}
function get_time(str) {
	if ( str !~ /....-..-..T..:..:../) { return 0; }
	split(str,month_date,"-");
	year_number=month_date[1];
	month_number=month_date[2];
	split(month_date[3],day_numbers,"T")
	day_number=day_numbers[1];
	split(str,time_seg,"T");
	split(time_seg[2],dhmi,":");
	hours=dhmi[1];
	minutes=dhmi[2];
	split(dhmi[3],seconds_seg,"+")
	seconds=seconds_seg[1];
	timet=(month_number*31*24*60*60) + (day_number*24*60*60) + (hours*60*60) + (minutes*60) + seconds;
	return timet
}
