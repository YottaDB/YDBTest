#!/usr/local/bin/tcsh -f
# This script just calls the stress runs. This script exists so that the callcan be backgrounded

if ("init" == "$1") then
$GTM << GTM_EOF
do init^concurr("$2","$3")
GTM_EOF

endif

if ("run" == "$1") then
$GTM << GTM_EOF
do run^concurr($2)
do verify^concurr
GTM_EOF

endif
