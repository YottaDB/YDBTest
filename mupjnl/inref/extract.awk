#################################################################
#								#
# Copyright 2003, 2014 Fidelity Information Services, Inc	#
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
####################################
# Byte layout of journal record
# ----------------------------------
#    Offset     Field             Size
#    -------------------------------------
#         0 <-- jrec_type     --> 1 byte
#         1 <-- size          --> 3 bytes
#         4 <-- pini_addr     --> 4 bytes
#         8 <-- time          --> 4 bytes
#        12 <-- checksum      --> 4 bytes
#        16 <-- tn            --> 8 bytes
#        24 <-- seqno         --> 8 bytes (for update records)
#        32 <-- stream_seqno  --> 8 bytes (for update records)
#        40 <-- ... variable length content
#
####################################
# PLAIN extract : YDBJEX08
# -------------------------
# NULL    00\time\tnum\pid\clntpid\jsnum
# PINI(U) 01\time\tnum\pid\nnam\unam\term\clntpid\clntnnam\clntunam\clntterm
# PINI(V) 01\time\tnum\pid\nnam\unam\term\mode\logintime\image_count\pname\clntpid\clntnnam\clntunam\clntterm\clntmode\clntlogintime\clntimage_count\clntpname
# PFIN    02\time\tnum\pid\clntpid
# EOF     03\time\tnum\pid\clntpid\jsnum
# KILL    04\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# SET     05\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
# ZTSTART 06\time\tnum\pid\clntpid\token
# ZTCOM   07\time\tnum\pid\clntpid\token\partners
# TSTART  08\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq
# TCOM    09\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\partners\tid
# ZKILL   10\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# ZTWORM  11\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\ztwormhole
# ZTRIG   12\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# LGTRIG  13\time\tnum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\lgtrig
#
# DETAIL extract : YDBJDX07
# --------------------------
# PINI(U) time\tnum\chksum\pid\nnam\unam\term\clntpid\clntnnam\clntunam\clntterm
# PINI(V) time\tnum\chksum\pid\nnam\unam\term\mode\logintime\image_count\pname\clntpid\clntnnam\clntunam\clntterm\clntmode\clntlogintime\clntimage_count\clntpname
# PFIN    time\tnum\chksum\pid\clntpid
# EOF     time\tnum\chksum\pid\clntpid\jsnum
# KILL    time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# TKILL   time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# UKILL   time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# SET     time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
# TSET    time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
# USET    time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node=sarg
# ZTSTART time\tnum\chksum\pid\clntpid\token
# ZTCOM   time\tnum\chksum\pid\clntpid\token\partners
# TSTART  time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq
# TCOM    time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\partners\tid
# ZKILL   time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# TZKILL  time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# UZKILL  time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# INCTN   time\tnum\chksum\pid\clntpid\opcode\incdetail
# EPOCH   time\tnum\chksum\pid\clntpid\jsnum\blks_to_upgrd\free_blocks\total_blks
# PBLK    time\tnum\chksum\pid\clntpid\blknum\bsiz\blkhdrtn\ondskbver
# AIMG    time\tnum\chksum\pid\clntpid\blknum\bsiz\blkhdrtn\ondskbver
# ZTWORM  time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\ztwormhole
# TZTWORM time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\ztwormhole
# UZTWORM time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\ztwormhole
# NULL    time\tnum\pid\clntpid\jsnum
# ZTRIG   time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# TZTRIG  time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# UZTRIG  time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\nodeflags\node
# TLGTRIG time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\lgtrig
# ULGTRIG time\tnum\chksum\pid\clntpid\token_seq\strm_num\strm_seq\updnum\lgtrig
#
# Legend
# -------
# All hexadecimal fields will have a 0x prefix. All numeric fields otherwise are decimal.
#
# tnum           : Transaction number
# chksum         : Checksum for this record
# pid            : Process id that wrote this jnl record
# clntpid        : If non-zero, it is the pid of the GT.CM client that initiated this update on the server side.
# jsnum          : Journal Sequence Number
# token          : Unique 8-byte token
# token_seq      : If replication is true, it is the journal sequence number. If not, it is a unique 8-byte token.
# strm_num       : If replication is true and this update originated in a non-supplementary instance but got replicated and
#                     played on a supplementary instance, this number is a non-zero value anywhere from 1 to 15 (both
# 		    inclusive) indicating the non-supplementary stream #.
# 		 In all other cases, this stream # value is 0.
# 		 In case of an EPOCH record, anywhere from 0 to 16 such "strm_num" numbers might be displayed depending on
# 		 	how many non-supplementary or supplementary streams are active.
# strm_seq       : If replication is true and this update originated in a non-supplementary instance but got replicated and
#                     played on a supplementary instance, this is the journal sequence number of the update on the
# 		    originating non-supplementary instance.
#                  If replication is true and this update originated in a supplementary instance, this is the journal sequence
# 		    number of the update on the originating supplementary instance.
# 		 In all other cases, this stream sequence number is 0.
# 		 Note that the journal seqno is actually 1 more than the most recent update originating on that stream #.
# 		 In case of an EPOCH record, anywhere from 0 to 16 such "strm_seq" numbers might be displayed depending on
# 		 	how many non-supplementary or supplementary streams are active.
# updnum         : =n where this is the nth update in the TP or ZTP transaction. n=1 for the 1st update etc. 0 for non-TP.
# nodeflags      : decimal number to be converted into binary format and then interpreted. Currently only 5 bits are used.
#                      If  1 (i.e. 00001 binary) => update is journaled but NOT replicated (e.g. update inside of a trigger)
#                      If  2 (i.e. 00010 binary) => update is to a global that had at least one trigger defined (even though
# 		     					it was not necessarily invoked for this particular update)
#                      If  4 (i.e. 00100 binary) => $ZTWORMHOLE at the time of this update is the "" string
#                      If  8 (i.e. 01000 binary) => update did not invoke any triggers even if they existed (e.g. MUPIP LOAD)
# 		     If 16 (i.e. 10000 binary) => whether the update (set or kill) is a duplicate. In case of a KILL, it is
# 		     			a kill of some non-existing node aka duplicate kill. Note that the dupkill occurs
# 					only in case of the update process. In case of GT.M, the KILL is entirely skipped.
# 					In both cases (duplicate set or kill), only a jnl record is written, the db is untouched.
#                      Combinations of the above bits would mean each of the individual bit characteristics.
#                              e.g. 00011 => update was inside trigger and to a global that had at least one trigger defined
#                      Certain bit combinations are impossible.
#                              e.g. 01001 since any update that does not invoke triggers is always replicated
# node           : Key that is being updated in a SET or KILL
# sarg           : Right-hand side argument to the SET (i.e. value that the key is being SET to)
# partners       : Number of journaled regions participating in this TP or ZTP transaction (TCOM/ZTCOM record written in this TP/ZTP)
# opcode         : Inctn opcode. See gdsfhead.h inctn_opcode_t for all possible values.
# blknum         : Block number corresponding to a PBLK or AIMG or INCTN record.
# bsiz           : Block size from the header field of a PBLK or AIMG record.
# blkhdrtn       : Transaction number from the block header of a PBLK or AIMG record.
# ondskbver      : On disk block version of this block at the time of writing the PBLK or AIMG record. 0 => V4, 1 => V5.
# incdetail      : 0 if opcode=1,2,3; blks_to_upgrd if opcode=4,5,6; blknum if opcode=7,8,9,10,11,12,13
# ztwormhole     : string corresponding to $ZTWORMHOLE
# lgtrig         : string corresponding to trigger load
# blks_to_upgrd  : # of new V4 format bitmap blocks created if opcode=4,5; csd->blks_to_upgrd if opcode=6
# free_blocks    : # of free blocks in the db file header at the time of writing the EPOCH
# total_blks     : # of total blocks in the db file header at the time of writing the EPOCH
# fully_upgraded : 1 if the db was fully upgraded (indicated by a dse dump -file -all) at the time of writing the EPOCH
#
# (U)    : Unix
# (V)    : VMS
#
# The fundamental update records are SET, KILL, ZKILL, ZTWORM, LGTRIG and ZTRIG.
# In the detailed journal extract
#         T variant of an update record (e.g. TSET) is printed if this is the FIRST update in the transaction in this region.
#         U variant of an update record (e.g. USET) is printed if this is NOT the FIRST update in the transaction in this region.
#
# Notes
# ------
# NULL record is possible only when using replication and external M-filters.
# It is not usually seen in journal files.

BEGIN {
	if ("" == host) host = "IMPOSSIBLEHOSTNAME"
	if ("" == user ) user = "IMPOSSIBLEUSERNAME"
	if ("" == strm_seqno_zero ) strm_seqno_zero = "TRUE"
	FS="\\"
	OFS="\\"
}

{
	token_seq_no_seen = 0
	nodeflags_seen = 0
	strm_seq_no_seen = 0
}
/ :: / {
	detail_field_offset = 1
	detailed = 1
}

/^01/ || / PINI / {
	imagecntfield = 10 + detail_field_offset
	pnamefield = 11 + detail_field_offset
	pidfield = 4 + detail_field_offset
	split($0,line,"\\");
	pid[++pidtotal]=line[pidfield]
	if ("" != line[pnamefield]) pname[++pnametotal]=line[pnamefield]
	if (vms) $imagecntfield="#IMAGECNT#"
	if (/^01/)
	{
		usern[++usertotal]=line[6]
	} else
	{
		usern[++usertotal]=line[7]
	}
}

(/^06/ || / ZTSTART/) || (/^07/ || / ZTCOM /) {
	token_seq_field = 6 + detail_field_offset
	token_seq_no_seen = "TOKEN";
}
(/^04/ || / KILL / || / .KILL /) || (/^05/ || / SET / || / .SET /) || (/^08/ || / TSTART /) || (/^09/ || / TCOM /) || (/^10/ || / ZKILL / || / .ZKILL /) {
	token_seq_field = 6 + detail_field_offset
	token_seq_no_seen = "TOKENSEQ";
	strm_seq_field = 8 + detail_field_offset
	strm_seq_no_seen = "STREAMSEQ";
}

(/^04/ || / KILL / || / .KILL /) || (/^05/ || / SET / || / .SET /) || (/^10/ || / ZKILL / || / .ZKILL /) {
	nodeflags_field = 10 + detail_field_offset
	nodeflags_seen = 1
}

(0 != token_seq_no_seen) {
	found = 0;
	split($0,line,"\\");
	linestr="" line[token_seq_field];	# concatenate with "" to coerce number into a string.
					 	# This way we will not lose precision in case token has more than 17 decimal digits
	last_token_seq_no = linestr
	# if this is the first tokenseqno, add it to the associative array right away.
	# the key is the actual tokenseqno to be masked, the value is the serial number of the mask
	if (! tokenseqtotal) token_seq[linestr]=++tokenseqtotal
	# if this tokenseqno is alreay in the associative array, just note down the serial number of the mask
	if (token_seq[linestr])
	{
		found = 1;
		tokenseqno =token_seq[linestr];
	}
	# if this tokenseqno is not already in the associative array, add it.
	if (! found)
	{
		token_seq[linestr]=++tokenseqtotal
		tokenseqno = token_seq[linestr]
	}
	# if tokenseqno is non-zero, mask it off.
	if ("0" != linestr)
		gsub("^"linestr"$","#TOKENSEQ"tokenseqno"#",$token_seq_field)
}

#-- for A->P and P->Q stream seqno will be equal to token seqno. For all the other cases it will be 0
 (0 != strm_seq_no_seen) {
 	found = 0;
 	split($0,line,"\\");
 	linestr="" line[strm_seq_field];	# concatenate with "" to coerce number into a string.
 					 	# This way we will not lose precision in case seq no has more than 17 decimal digits
	to_check = last_token_seq_no
	strm_mask = "#UNEXPECTED_STRMSEQNO#"
	if("TRUE" == strm_seqno_zero)
		to_check = 0
	if (to_check == linestr)
		strm_mask = "#STRMSEQNO#"
	if (! vms)
		gsub("^"linestr"$",strm_mask,$strm_seq_field)
 }

(0 != nodeflags_seen) {
	$nodeflags_field = "#NODEFLAGS#"
}

{
	#mask off checksum for detailed extract, it is a string of decimal digits
	if ((detailed) && ($4 ~ /[0-9][0-9]*/)) $4="#CHKSUM#"
	#mask off PID's.
	pidfield = 4 + detail_field_offset
	if (1 == maskpid)
	{
		# Unconditionally mask off PID field.
		$pidfield = "#PID#"
	} else
	{
		for(x=1;x<=pidtotal;x++)
		{
			# pid is 4th field in nodetail extract format and 5th field in the detail extract format
			if ($pidfield == pid[x]) $pidfield = "#PID"x"#"
		}
	}
	if (vms)
	{
		#mask off PNAME's
		for(x=1; x<=pnametotal;x++)
			gsub("\\\\"pname[x]"\\\\","\\#PNAME"x"#\\") #need to double-escape
	}
	#mask off hostname
	hoststr=host"[a-z.]*"
	sub(hoststr,"#HOST#")
	#mask off USERNAMEs
	for(x=1; x<=usertotal;x++)
		gsub("\\\\"usern[x]"\\\\","\\#USER"x"#\\") #need to double-escape
	#mask off date/time
	gsub(/\\[0-9]*,[0-9]*\\/,"\\#TIMESTAMP#\\")
	#mask off username
	gsub(user,"#USER#")

	# filter out UTF-8 strings that appears with the header if the CHSET mode on which the test ran is UTF-8
	if ( $0 ~ /UTF-8/ ) gsub(/[ ]*UTF-8/,"")
	print;
}
