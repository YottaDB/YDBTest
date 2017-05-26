#!/usr/local/bin/tcsh -f
#
setenv gtmgbldir "mumps.gld"
$gtm_tst/com/dbcreate.csh mumps 1 . . . 1000 256
#
$GTM << GTM_EOF
w "s ^in0=0",!  s ^in0=0
w "d in0^dbfill(""kill"")",!  d in0^dbfill("kill") 
set quote="""",JOBPARM=quote_"set"_quote	; needed to pass parameters to ^job
set jmjoname="very_very_long_filename_job"	; used by ^job
set jmaxwait=0	; used by ^job
do ^job("in0^dbfill",1,"JOBPARM")
w "d in1^dbfill(""set"")",!  d in1^dbfill("set") 
do wait^job
GTM_EOF
#
$gtm_tst/com/dbcheck.csh "mumps"
#
ls very*
