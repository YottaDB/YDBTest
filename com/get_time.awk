#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
##############################################################################
# returns the number of minutes sine 1/1/YEAR  1:0:SS (seconds are not counted)
# str has to be in the format: Jul 16 16:58:04
# does not recognize year
BEGIN {
    months="JAN#FEB#MAR#APR#MAY#JUN#JUL#AUG#SEP#OCT#NOV#DEC"
}

function get_time(str) {
	if ( str !~ /... ..? ..:..:../) {return 0 }
	split(str,month_date," ");
	monthix=month_date[1]
	monthstmp = months
	monthi=toupper(monthix)
	monthi_rep = monthi".*"
	gsub(monthi_rep,"",monthstmp)
	monthi = gsub("#","",monthstmp)+1
	itime=month_date[3]
	split(itime,dhmi,":");
	timet=(monthi-1)*31*24*60*60 + (month_date[2]-1)*24*60*60 + (dhmi[1]-1)*60*60 + dhmi[2]*60 + dhmi[3]
	return timet
}
