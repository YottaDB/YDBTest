#!/usr/local/bin/tcsh -f

unsetenv gtmprincipal
unsetenv gtm_principal

setenv gtmprincipal	"abcdefgh"
$GTM << GTM_EOF
w \$p,!
GTM_EOF

setenv gtm_principal	"ijklmnop"
$GTM << GTM_EOF
w \$p,!
GTM_EOF

