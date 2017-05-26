#!/usr/local/bin/tcsh -f
$MUPIP backup -dbg -online $1 $2 >& mupip_bkgrnd_backup.out &
$MUPIP freeze -dbg -ON $1 >& mupip_bkgrnd_freeze.out &
$MUPIP integ -dbg -region $1 >& mupip_bkgrnd_integ.out &
