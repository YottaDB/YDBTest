#################################################################
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

# Sanitize the output of Online Rollback for a clean reference file
/RLBKJNSEQ/ {
	if (resyncseqnolist >= rollseqno && jnlseqno >= rollseqno) {
		if ($(NF-1)>rollseqno) {
			print "TEST-E-FAIL : RESYNC Seqno does not match RLBKJNSEQNO"
		}
	} else {
		if ("" != debug) {print "TEST-I-INFO : RESYNC Seqno is less than rollseqno"}
	}
}
/(YDB-E-|JNLSUCCESS|ORLBKCMPLT)/{
	print $0
}
