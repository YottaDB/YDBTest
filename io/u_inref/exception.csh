#!/usr/local/bin/tcsh -f
# EXCEPTION
unset gtm_ztrap_form
$GTM << EOF
do ^except
halt
EOF

# We are testing $ztrap here
if ($?gtm_etrap) then
	set save_gtm_etrap="$gtm_etrap"
endif
unsetenv gtm_etrap

setenv gtm_ztrap_form code
$GTM << EOF
do ^except
halt
EOF

setenv gtm_ztrap_form adaptive
$GTM << EOF
do ^except
halt
EOF

unset gtm_ztrap_form

if ($?save_gtm_etrap) then
	setenv gtm_etrap "$save_gtm_etrap"
endif
