#!/usr/local/bin/tcsh -f
#
# $1 = PATTERN ; regular expression for set of journal files (e.g. "*.mjl", "mumps*.mjl" etc.)
# $2 = OPTION ; -SHOW=option to use (e.g. "HEADER", "ALL" etc.)
# $3 = OUTPUT_FILE
#
# Operation : Does mupip journal -show=OPTION on all files matching PATTERN and redirects to OUTPUT_FILE
#

foreach file ($1)
	$MUPIP journal -show=$2 -forward -noverify $file >>&! $3
end
