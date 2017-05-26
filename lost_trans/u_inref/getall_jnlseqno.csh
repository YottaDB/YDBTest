#! /usr/local/bin/tcsh -f
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
#
setenv msg ""
if ($1 != "") setenv msg $1

echo $msg >>&  jnlallseqno.log

$gtm_tst/com/get_reg_list.csh > gde_reg.log
foreach region (`cat gde_reg.log`)
$DSE << DSE_EOF >>&! jnlallseqno.log
find -REG=$region
d -f
quit
DSE_EOF

end

