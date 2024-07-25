#!/usr/local/bin/tcsh -f
#################################################################
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

setenv ydb_prompt 'GTM>'	# So can run the test under GTM or YDB
setenv ydb_msgprefix "GTM"	# So can run the test under GTM or YDB

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE307442)

SOCKET device USE handles errors associated with device parameters CONNECT or LISTEN and IOERROR="T"
appropriately. Previously, such errors could cause odd behavior including segmentation violation
(SIG-11). This was only seen in development and not reported by a customer. (GTM-DE307442)

CAT_EOF

echo "# ********************************************************************************************"
echo "# Test SOCKET USE device parameter errors (details at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/611#note_2016600532)"
echo "# We expect a graceful %GTM-E-SOCKBIND error (Address already in use) below."
echo "# GT.M V7.0-003 used to SIG-11 in PRO builds and Assert fail in DBG builds"
$gtm_dist/mumps -direct << GTM_EOF
set s="socket" open s:::"SOCKET" set sockname="socketbad"
use s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
use s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
GTM_EOF

echo "# ********************************************************************************************"
echo "# Test SOCKET OPEN device parameter errors (details at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/611#note_2016610296)"
echo "# We expect a graceful %GTM-E-SOCKBIND error below followed by a DESC=4 in the socketgood line of the zshow d output."
echo "# GT.M V7.0-003 used to show DESC=7 instead which indicated a file descriptor leak in the OPEN commands that errored out."
$gtm_dist/mumps -direct << GTM_EOF
set s="socket" open s:::"SOCKET" set sockname="socketbad"
open s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
open s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
open s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
open s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
set sockname="socketgood"
open s:(LISTEN=sockname_":LOCAL":IOERROR="TRAP")
zshow "d"
GTM_EOF

