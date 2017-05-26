#!/usr/local/bin/tcsh  -f
# Starts the GT.CM servers on all the platforms

echo "Starting the GT.CM Servers..."
# First the first
setenv start_time `date +%H_%M_%S`

$sec_shell "SEC_SHELL_GTCM SEC_GETENV_GTCM; cd SEC_DIR_GTCM; $gtm_tst/com/GTCM_SERVER.csh PORTNO_GTCM $start_time >&! SEC_DIR_GTCM/gtcm_start_${start_time}.out"
