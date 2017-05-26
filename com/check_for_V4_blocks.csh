#!/usr/local/bin/tcsh -f 
# check each DAT file for V4 blocks

set ts=`date +%Y%d%m_%H%S`

$DSE all -dump -all >&! check_for_V4_blocks_${ts}.outx
$grep "Database is Fully Upgraded" check_for_V4_blocks_${ts}.outx | $grep "FALSE" >&! /dev/null
set stat = $status
if (0 == $stat) then
	echo "V4"
else
	echo "V5"
endif
