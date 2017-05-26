#!/usr/local/bin/tcsh -f

# disable implicit mprof testing to prevent failures due to extra memory footprint;
# see <mprof_gtm_trace_glb_name_disabled> for more detail
unsetenv gtm_trace_gbl_name
$gtm_dist/mumps -run c001087
