#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Input should be of the below form
# date +"%Y %m %d %H %M %S %Z"
# echo "2013 11 03 01 50 00 EDT" "2013 11 03 01 10 00 EST" | awk -f diff_time.awk
# set starttime = "2014 03 09 01 50 00 EST" ; set nowtime = "2014 03 09 03 20 00 EDT" ; echo $starttime $nowtime | awk -f diff_time.awk
{
	if ( ($7 !~ /[A-Z]+/) || ($14 !~ /[A-Z]+/) )
		{
			printf "Input format incorrect. 7th and 14th character expects timezone code\n"
			exit
		}
	if ("EDT" == $7) { $7=1} else {$7=0}
	if ("EDT" == $14) { $14=1} else {$14=0}
	begin=sprintf("%d %d %d %d %d %d %d",$1,$2,$3,$4,$5,$6,$7)
	end=sprintf("%d %d %d %d %d %d %d",$8,$9,$10,$11,$12,$13,$14)
	TB=mktime(begin)
	TE=mktime(end)
	secs=TE-TB
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

