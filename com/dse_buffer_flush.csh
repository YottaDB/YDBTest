#!/usr/local/bin/tcsh -f

# Usage:
# $gtm_tst/com/dse_buffer_flush.csh
# $gtm_tst/com/dse_buffer_flush.csh -region AREG DREG FREG

# This tool does a dse buffer_flush for each of the regions
# Optionally pass a list of regions

set opt_array      = ( "\-region" )
set opt_name_array = ( "reglist" )
source $gtm_tst/com/getargs.csh $argv

if ($?reglist) then
	set region_list = "$reglist"
else
	$gtm_tst/com/create_reg_list.csh
	set region_list = "`cat reg_list.txt`"
endif

echo "dse buffer flush begins : `date`" >>&! dse_buffer_flush.out
echo "" >>&! dse_buffer_flush.out
foreach region ($region_list)
	$DSE >>&! dse_buffer_flush.out << EOF
find -region=$region
buffer_flush
EOF

end
echo "" >>&! dse_buffer_flush.out
echo "dse buffer flush ends : `date`" >>&! dse_buffer_flush.out
