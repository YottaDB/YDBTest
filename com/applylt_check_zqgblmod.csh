#!/usr/local/bin/tcsh -f
#
# applylt.csh <file_name>
#
# Apply lost transaction depending on $ZQGBLMOD value.
if ($1 == "") then
	echo "No file name found for lost transactions!"
	exit 1
endif

$convert_to_gtm_chset $1
$GTM << xyz
set checkzqgblmod=1
do ^umjrnl("$1")
halt
xyz
