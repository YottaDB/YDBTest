#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Include "-f get_time.awk" in the command line

BEGIN{	timei=get_time(before)
	timef=get_time(after)
}
{  	timeactual = get_time($1" "$2" "$3)
	if ((timei <= timeactual) && (timeactual <= timef))
	    print;
}
