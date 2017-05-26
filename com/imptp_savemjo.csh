#!/usr/local/bin/tcsh -f
# save the prior imptp (and friends) MJ[OE] files
# test/com/job.m creates MJ[OE] files with the default format
# <label_routine><job id>.mj[oe]<job count>

# if the test is not using a jobid default to zero
set mjobid=0
if ($?gtm_test_jobid) then
	set mjobid=$gtm_test_jobid
endif

set ts=`date +%Y%m%d_%H%M%S`
set savedir=savedjoboutput_${mjobid}_${ts}

# what label is used for the MJ[OE] file name
if ($gtm_test_dbfill == "IMPTP" || $gtm_test_dbfill == "IMPZTP") then
	set label="impjob_imptp"
else if ($gtm_test_dbfill == "IMPRTP") then
	set label="imprjob_imprtp"
else if ($gtm_test_dbfill == "SLOWFILL") then
	set label="slowjob_slowfill"
else if ($gtm_test_dbfill == "FIXTP") then
	set label="fill_fixtp"
endif

# don't bother creating the directory if there are no MJO files to save
ls ${label}${mjobid}.mj[oe][0-9] >&! /dev/null || exit

mkdir -p $savedir
# move the files so processes that have them open will continue updates
mv ${label}${mjobid}.mj[oe][0-9] $savedir/ >&! /dev/null
