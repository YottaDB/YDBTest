#! /usr/local/bin/tcsh -f
#
# This is unicode version of mupip_backup subtest
#
$switch_chset UTF-8

# switch_chset is done before calling the subtests containing unicode characters
# If this is not done, the subtests fail to understand the unicode characters properly in HP-UX and solaris

$gtm_tst/$tst/u_inref/unicode_mupip_backup_base.csh
