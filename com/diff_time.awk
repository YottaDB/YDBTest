#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Input should be of the below form
# date +"%Y %m %d %H %M %S %:::z"
#
# For example,
# echo "2013 11 03 01 50 00 -04" "2013 11 03 01 10 00 -05" | awk -f diff_time.awk
# echo "2024 04 30 23 00 42 +07" "2024 04 30 23 00 44 +07" | awk -f diff_time.awk
#
{
	begin=sprintf("%d %d %d %d %d %d",$1,$2,$3,$4,$5,$6)
	end=sprintf("%d %d %d %d %d %d",$8,$9,$10,$11,$12,$13)
	TB=mktime(begin)
	TE=mktime(end)
	secs=TE-TB
	if ($7 != $14)
		secs += ($7 - $14) * 3600;
	if (1==full)
		{
			d=int(secs/86400)
			secs=secs-(d*86400)
			h=int(secs/3600)
			secs=secs-(h*3600)
			m=int(secs/60)
			secs=secs-(m*60)
			printf "%02d:%02d:%02d:%02d\n",d,h,m,secs

		}
	else { print secs }
}

