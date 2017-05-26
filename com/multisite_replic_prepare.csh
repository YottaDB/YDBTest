#!/usr/local/bin/tcsh -f
##########################################################################################################
# wrapper script for MULTISITE environment preparation
# The script helps to log the output into a file on verbose mode for details.
##########################################################################################################
#
if (( 1 != $#argv ) && ( 2 != $#argv )) then
	echo "TEST-E-MULTIWAY_REPLIC_PREPARE ERROR"
	echo "Pls. specify the number of instances for which the directories and env. has to be prepared for"
	echo "Usage:"
	echo "source \$gtm_tst/com/multisite_replic_prepare.csh <no_of_instances>"
	exit 1
endif
source $gtm_tst/com/multisite_replic_prepare_base.csh >>&! multisite_replic_prepare.log
if ($status) then
	echo "MSR-E-PREPARE_ERROR, initial preparations failed, abort the test"
	echo "Check the output at multisite_replic_prepare.log"
	exit 1
endif
#
