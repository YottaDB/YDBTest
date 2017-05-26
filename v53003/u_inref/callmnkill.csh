#!/usr/local/bin/tcsh -f
#Since the KILL's will be waiting when white box testing is enabled.Start then in background
( $gtm_exe/mumps -run mnkill^c002783 >&! mnkill.outx ) &
