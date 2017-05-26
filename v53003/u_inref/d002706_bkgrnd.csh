#!/usr/local/bin/tcsh -f

# Helper script to start a reorg process in the background.
#
# $1 = Number used for the log file.

# Extension used is "logx" (instead of "log") since we dont want GTM-F-FORCEDHALT message to be caught by test framework.
$MUPIP reorg >& mupip_reorg_$1.logx &
