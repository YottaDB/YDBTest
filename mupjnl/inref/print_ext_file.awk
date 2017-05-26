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
/^[ \t]*#/ {next}

BEGIN {
 type[2] = "PFIN"
 type[1] = "PINI"
 type[3] = "EOF"
 type[4] = "KILL"
 type[5] = "SET"
 type[6] = "ZTSTART"
 type[7] = "ZTCOM"
 type[8] = "TSTART"
 type[9] = "TCOM"
 type[10] = "ZKILL"
 type[11] = "ZTWOR"
 type[12] = "ZTRIG"
 type[13] = "LGTRIG"
 }

{
num = split($0,line," ");
if(num > 2)
 split(line[field],rec,"\\");
else
 split(line[1],rec,"\\");
print type[0+rec[1]]
}
