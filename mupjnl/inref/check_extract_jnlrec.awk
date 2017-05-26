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
#01 PINI(U) 01\time\tnum\pid\nnam\unam\term\clntpid\clntnnam\clntunam\clntterm
#01 PINI(V) 01\time\tnum\pid\nnam\unam\term\mode\logintime\image_count\pname\clntpid\clntnnam\clntunam\clntterm\clntmode\clntlogintime\clntimage_count\clntpname
#02 PFIN    02\time\tnum\pid\clntpid
#03 EOF     03\time\tnum\pid\clntpid\jsnum
#04 KILL    04\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
#05 SET     05\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
#06 ZTSTART 06\time\tnum\pid\clntpid\token
#07 ZTCOM   07\time\tnum\pid\clntpid\token\partners
#08 TSTART  08\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq
#09 TCOM    09\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\partners\tid
#10 ZKILL   10\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
#11 ZTWORM  11\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\ztwormhole
#12 ZTRIG   12\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
#13 LGTRIG  13\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\lgtrig
/^01/   {tot["PINI"]++}
/^02/   {tot["PFIN"]++}
/^03/   {tot["EOF"]++}
/^04/   {tot["KILL"]++}
/^05/ 	{tot["SET"]++}
/^06/  	{tot["ZTSTART"]++}
/^07/  	{tot["ZTCOM"]++}
/^08/  	{tot["TSTART"]++}
/^09/  	{tot["TCOM"]++}
/^10/  	{tot["ZKILL"]++}
/^11/  	{tot["ZTWOR"]++}
/^12/  	{tot["ZTRIG"]++}
/^13/  	{tot["LGTRIG"]++}
detail && (1 < NF) {
	if ($0 ~ /::/)
		tot[$4]++;
	else if ($2 !~ /UTF-8/)
		tot[$1]++; #TSET and FSET lines
}
END {
	for (i in tot)
		print "   " i "\t" tot[i]
	TOT_KILL = tot["KILL"] + tot["FKILL"] + tot["GKILL"] + tot["TKILL"] + tot["UKILL"]
	TOT_ZKILL = tot["ZKILL"] + tot["FZKILL"] + tot["GZKILL"] + tot["TZKILL"] + tot["UZKILL"]
	TOT_SET = tot["SET"] + tot["FSET"] + tot["GSET"] + tot["TSET"] + tot["USET"]

	print "   TOT_KILL   " TOT_KILL
	print "   TOT_ZKILL  " TOT_ZKILL
	print "   TOT_SET    " TOT_SET
	for (i in tot)
		TOTAL += tot[i]
	print "   TOTAL(incl. (Z)TS):   " TOTAL
	print "   TOTAL(excl. (Z)TS):   " TOTAL - tot["ZTSTART"] - tot["TSTART"]
}

