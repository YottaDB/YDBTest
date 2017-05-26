#!/usr/local/bin/tcsh -f
#
# C9J04003109 [Roger] Provide gtm_prompt environment variable to initialize $ZPROMPT
#
# This just shows that one can set the GT.M prompt with the environment variable
# 
setenv gtm_prompt NEWGTMPROMPT

$GTM << GTM_EOF 
GTM_EOF

unsetenv gtm_prompt
