#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Usage:
# $gtm_tst/com/dse_command.csh -region AREG CREG EREG -do 'change -f -current_tn=0xFFFFFFFD93FFFF41'
# $gtm_tst/com/dse_command.csh -do 'change -f -current_tn=0xFFFFFFFD93FFFF41'

# This tool executes a given command on all regions
# Optionally pass a list of regions

set opt_array      = ( "\-region" "\-do")
set opt_name_array = ( "reglist"  "do"  )
source $gtm_tst/com/getargs.csh $argv

if ($?reglist) then
	set region_list = "$reglist"
else
	$gtm_tst/com/create_reg_list.csh
	set region_list = "`cat reg_list.txt`"
endif

echo "" >>&! dse_commands.out
foreach region ($region_list)
	$DSE >>&! dse_commands.out << EOF
find -region=$region
$do
EOF

end
echo "" >>&! dse_commands.out
