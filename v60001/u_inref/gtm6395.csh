#!/usr/local/bin/tcsh -f
# 
# GTM-6395. SET @"X(I)"=$$I must evaluate left hand side BEFORE evaluating right hand side
#
$gtm_tst/com/dbcreate.csh mumps 1
setenv gtm_side_effects 1
$GTM << GTM_EOF
        do ^gtm6395
GTM_EOF
$gtm_tst/com/dbcheck.csh
