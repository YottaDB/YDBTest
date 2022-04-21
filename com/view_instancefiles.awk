#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
BEGIN{
	maskn = split(ignore,ignorearray,",")
	anything = ".*"
	masked = " ##FILTERED##"
}
{
	if ("filter" == funcx)
	{
		# filter out run-specific fields, such as timestamps, since view_instancefiles.csh is not intended to compare these fields.
		gsub(/[0-9][0-9][0-9][0-9]\/[0-9][0-9]\/[0-9][0-9] [0-9][0-9]:[0-9][0-9]:[0-9][0-9]/,"..../../.. ..:..:..");
		gsub(/Instance File Creator Pid *[0-9]* .0x[0-9a-fA-F]*./, "Instance File Creator Pid                 PIDINDECIMAL [0xPIDINHEX]")
		gsub(/LMS Group Creator Pid *[0-9]* .0x[0-9a-fA-F]*./, "LMS Group Creator Pid                     PIDINDECIMAL [0xPIDINHEX]")
		gsub(/LMS Group Creator PID *[0-9]* .0x[0-9a-fA-F]*./, "LMS Group Creator PID          PIDINDECIMAL [0xPIDINHEX]")
		gsub(/: Creator Process ID  *[0-9]* .0x[0-9a-fA-F]*./,": Creator Process ID             PIDINDECIMAL [0xPIDINHEX]")

		if ("Connect Sequence Number" == ENVIRON["view_instancefiles_filter"])
		{	# Caller test has asked us to filter out this pattern.
			gsub("SLT #[ 0-9][0-9] : Connect Sequence Number .*", "SLT # X : Connect Sequence Number             ##FILTERED##");
		}

		for (i in ignorearray) {
			gsub(ignorearray[i] anything,ignorearray[i] masked)
		}
		print

	}
	if ("history" == funcx)
	{
		if (printhist) print;
		if ($0 ~ /^History Records/) printhist=1
	}
}

