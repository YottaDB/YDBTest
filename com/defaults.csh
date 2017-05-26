#!/usr/local/bin/tcsh -fx
#not to redefine already defined environment variables
$tst_awk -f $gtm_test_com_individual/process_defaults.awk $1 >! /tmp/__${USER}_test_suite_$$_defaults_tmp_csh
source /tmp/__${USER}_test_suite_$$_defaults_tmp_csh
if ($status) exit $status
