#!/usr/local/bin/tcsh -f
# Disable implicit mprof testing to prevent failures due to extra memory footprint;
# see <mprof_gtm_trace_glb_name_disabled> for more detail
unsetenv gtm_trace_gbl_name
setenv gtmdbglvl 1
source $gtm_tst/com/portno_acquire.csh >>& portno2.out
set portno2 = $portno
source $gtm_tst/com/portno_acquire.csh >>& portno1.out
$GTM << EOF
s portno=$portno
s portno2=$portno2
s hostname="$tst_org_host"
do ^gtm7413
h
EOF

# portno_release.csh reads the port number to be released from portno.out. Call it twice after renaming portnoX.out to portno.out each time
cp portno1.out portno.out
$gtm_tst/com/portno_release.csh
cp portno2.out portno.out
$gtm_tst/com/portno_release.csh
