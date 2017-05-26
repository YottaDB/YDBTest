#!/usr/local/bin/tcsh -f
if ( "$1" == "ALL" ) then
	$MUPIP backup -dbg -online '*' $2 >& backup.outx &
else
	$MUPIP backup -dbg -online $1 $2 >& backup.outx &
endif
set pid = $!
echo $pid >& backup.pid
