#!/usr/local/bin/tcsh

# This script is used by both journaltrigger and replictrigger to
# extract the journal files

# Extract the journal files
foreach db (*.mjl)
	$MUPIP journal -extract -noverify -forward -fences=none ${db} >>& extracts.log
end

foreach mjf (*.mjf)
	echo $mjf
	# Journal updates only show explicit updates to ^a(:) and ^e(:)
	# there is a kill of ^c and several zkills of ^b
	# Shows that the updates are in the correct journal file
	# AWK parsing shows $ZTWOrmhole when it is used
	# Transaction markers also shows the implicit TSTART/TCOMMIT to a trigger update
	$tst_awk -F "\\" '$0 !~ /(\^fired|"#LABEL"|"#TRHASH"|"[LB]HASH"|"CHSET")/ {if ($1 ~/^(0[4589]|1[210])/){if($1 ~/0[89]/){print $1;} else {print $1" "$NF}}}' $mjf
	$echoline | tr '#' '-'
end


