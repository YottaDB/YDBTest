#!/usr/local/bin/tcsh -f

set pid = $1
set log = $2
$grep PR_PCINVAL $log >> /dev/null
if !($status) then
	echo "Error in dbx. PR_PCINVAL found" 		>>&! $log
	echo "Try using pstack" 			>>&! $log
	$pstack $pid 					>>&! $log
	echo "Pflags information" 			>>&! $log
	$pflags $pid 					>>&! $log
endif
echo ""						>>&! $log
