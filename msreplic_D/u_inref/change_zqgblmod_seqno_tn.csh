#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This script will change the Zqgblmod Seqno and Zqgblmod Trans fields in the database fileheader.
# The reason we want to do that is to test if $ZQGBLMOD values are correct, so we want to "rewind"
# more than the test normally would.

# $1 is the desired seqno to set zqgblmod_seqno to in DECIMAL
# Determine db tn corresponding to $1 from the journal extract

set dec_seqno = $1
set hex_seqno = `$gtm_tst/com/radixconvert.csh d2h ${dec_seqno} | $tst_awk '{print $2}'`	# store seqno in hexadecimal
$DSE dump -file >& dse_dump_file_before_change.log
$gtm_tst/com/jnlextall.csh mumps >& jnlextall.out	# extract from mumps.mjl* files
# awk loses accuracy when transaction number (randomly set) is larger than 2**53, gtm loses accuracy at 2**60.
# Since we set transaction number till 2**63, use bc which works
set dec_tn = `$tst_awk -F\\ '$1 ~ /SET/ && $7 == '${dec_seqno}' {print $3 ; exit }' mumps.mjf*`
set hex_tn = `$gtm_tst/com/radixconvert.csh d2h ${dec_tn} | $tst_awk '{print $2}'`      # store tn in hexadecimal
$DSE change -file -zqgblmod_tn=${hex_tn}
$DSE change -file -zqgblmod_seqno=${hex_seqno}
$DSE dump -file >& dse_dump_file_after_change.log
