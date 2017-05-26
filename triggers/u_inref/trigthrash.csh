#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Re-use the database for each step but make a copy of it for debugging.
#
# disable implicit mprof testing to prevent failures due to extra memory footprint;
# see <mprof_gtm_trace_gbl_name_disabled> for more detail
unsetenv gtm_trace_gbl_name
#
# Also disable $gtm_boolean and $gtm_side_effects. This test uses gtmpcat which has some sensitivities to
# a lack of boolean-shortcutting so avoid explicit (by user) or implicit (by test randomization) setting
# of either of these flags (gtm_side_effects forces gtm_boolean).
#
setenv gtm_boolean 0	                # gtmpcat has a non-boolean dependency
setenv gtm_side_effects 0     	        # gtmpcat has a non-side-effect dependency
#
# Enable gtmdbglvl so we can use the memory statistics in the gtmpcat report.
#
setenv gtmdbglvl 1

# Set tpnotacidtime to its maximum possible value (to avoid false alarms of TPNOTACID messages in syslog)
setenv gtm_tpnotacidtime 30

setenv test_specific_trig_file "$gtm_tst/$tst/inref/trigtrc.trg"
$gtm_tst/com/dbcreate.csh .
$gtm_dist/mumps -run ^trigtrc
$gtm_tst/com/dbcheck.csh
mkdir trigtrc_bak
cp -p  mumps.* trigtrc_bak
#
# The trigger thrash tests have a dependence on lots of indirect cache entries
# so override the defaults to make sure indirect cache thrashing does not spur
# false storage leak errors
#
setenv gtm_max_indrcache_count 512
$echoline
$gtm_dist/mumps -run %XCMD 'do ^trigthrashdrv("trigthrash1",3,4,0,0)'
$gtm_tst/com/dbcheck.csh
mkdir trigthrash1_bak
cp -p  mumps.* trigthrash1_bak
#
$echoline
$gtm_dist/mumps -run %XCMD 'do ^trigthrashdrv("trigthrash2",3,4,0,0)'
$gtm_tst/com/dbcheck.csh
mkdir trigthrash2_bak
cp -p mumps.* trigthrash2_bak
#
# For this test, need the storage init debug flag on to detect reuse of released
# storage. Failures are marked by sig-11s and similar.
#
$echoline
setenv gtmdbglvl 0x40000
$gtm_dist/mumps -run %XCMD 'do ^trigthrashdrv("trigthrash3",5,4,0,0)'
$gtm_tst/com/dbcheck.csh
mkdir trigthrash3_bak
cp -p mumps.* trigthrash3_bak
unsetenv gtmdbglvl
