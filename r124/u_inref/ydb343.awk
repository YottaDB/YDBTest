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

BEGIN			{ donotprint = 0 }
			{ if (!donotprint) print $0; }
$1 == "YDB>zwrite"	{ donotprint = 1 }
$1 == "%YDB-I-CTRLC,"	{ donotprint = 0; print $0; }
END			{ }
