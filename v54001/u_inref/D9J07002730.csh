#!/usr/local/bin/tcsh -f
# D9J07-002730 - check MUPIP RUNDOWN status return for no region
echo Starting D9J07002730
$GDE exit
$MUPIP rundown -reg DEFAULT
echo $status
$MUPIP create
$MUPIP rundown -reg DEFAULT
echo $status
echo Ending D9J07002730
