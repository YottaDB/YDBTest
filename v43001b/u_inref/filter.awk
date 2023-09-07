#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

BEGIN	{reg["AREG"]=reg["BREG"]=reg["DEFAULT"]=1}
/%YDB-I-BACKUPTN, Transactions from/	{$4="XXXX"; $6="YYYY";}
/blocks saved./ 	{$1="X"}
/STOP issued/ 		{$NF="XXXX"}
{ 	for (r in reg)
	{
		gsub(r"_[0-9]*__[0-9]\\.",r"_XXXX__N.");
		gsub(r"_[0-9a-f]*_......",r"_YYYY_ZZZZZZ")
	}
}
{print}

