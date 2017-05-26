#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2003, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#Test Case # 27
unset backslash_quote
alias check_mjf 'unset echo; ($tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" \!:* | sed '"'"'s/\\/,/g'"'"' | $tst_awk -F, -f $gtm_tst/$tst/inref/extract_summary.awk | $grep -E "^\^|#Globals"); $gtm_exe/mumps -run mjfhdate \!:* > \!:*_date; set echo'
##NOTE extract_summary.awk ignores EPOCH records #BYPASSOK

$gtm_tst/com/dbcreate.csh . 1
$gtm_tst/com/abs_time.csh time00
sleep 1
$gtm_tst/com/jnl_on.csh

$gtm_exe/mumps -run ttest1^ttest
$gtm_tst/com/jnl_on.csh
$gtm_exe/mumps -run ttest2^ttest
$gtm_tst/com/jnl_on.csh
$gtm_exe/mumps -run ttest3^ttest
$gtm_tst/com/jnl_on.csh
sleep 1
$gtm_tst/com/abs_time.csh time4

#time3= time of the last record in the journal extract

$gtm_tst/com/backup_dbjnl.csh save "*.dat" mv nozip

# JOURNAL EXTRACT is issued when there are no database files in the current directory.
# JOURNAL EXTRACT might need to read the database file to get the collation information.
# To skip the JOURNAL EXTRACT from reading the database file, set the env variable
# gtm_extract_nocol to non-zero value.
setenv gtm_extract_nocol 1
set mjlfiles = `ls -1 *.mjl* | $tst_awk '{printf $0","} END{printf"\n"}' |sed 's/,$//g'`
echo "mjlfiles is $mjlfiles"
set echo

# First, let's get the complete set:
$MUPIP journal -extract=total.mjf -forward $mjlfiles
check_mjf total.mjf
unset echo

#set time3x = `grep '^03' total.mjf_date | $tail -n 1 | sed 's/.* //g;s/#.*//g;s/:/./g'`
set time3x = `$grep '^03' total.mjf_date | $tail -n 1 | sed 's/.* //g;s/#.*//g'`
set time3 = `date +'%Y.%m.%d.'``echo $time3x | sed 's/:/./g'``date +'.%Z'`
echo $time3 > time3
#delta0=time3-time0
#delta1=time3-time1
#delta2=time3-time2

set time00_abs = `cat time00_abs`
set time0_abs = `cat time0_abs`
set time1_abs = `cat time1_abs`
set time2_abs = `cat time2_abs`
set time4_abs = `cat time4_abs`
set time4_abs_tmp = (`cat time4_abs`)
set time3_abs = "$time4_abs_tmp[1] $time3x"
echo $time3_abs > time3_abs

set time00 = `cat time00`
set time0 = `cat time0`
set time1 = `cat time1`
set time2 = `cat time2`
set time3 = `cat time3`
set time4 = `cat time4`
set delta0 = "`echo $time0.$time3 | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1 | sed  's/^[0-9]*://g'`"
set delta1 = "`echo $time1.$time3 | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1 | sed  's/^[0-9]*://g'`"
set delta2 = "`echo $time2.$time3 | $tst_awk -F \. -f $gtm_tst/com/diff_time.awk -v full=1 | sed  's/^[0-9]*://g'`"

echo "delta0: $delta0, delta1: $delta1, delta2: $delta2"

set echo
################################################################################
$MUPIP journal -extract=after1.mjf -after=\"$time1_abs\" -forward $mjlfiles
check_mjf after1.mjf
#Expected result: Globals ^C, ^CC, ^BB, ^AA are extracted to after1.mjf
################################################################################
$MUPIP journal -extract=after2.mjf -after=\"$time1_abs\" -before=\"$time2_abs\" -forward $mjlfiles
check_mjf after2.mjf
#Expected result: Globals ^C, ^CC are extracted to after2.mjf
################################################################################
$MUPIP journal -extract=after3.mjf -after=\"$time3_abs\" -forward $mjlfiles
check_mjf after3.mjf
#Expected result: nothing is extracted to after3.mjf
################################################################################
$MUPIP journal -extract=before1_err.mjf -before=\"$delta0\" -forward $mjlfiles
#Expected result: nothing is extracted to before1.mjf because the delta0 is in wrong format
#Return status: Invalid -BEFORE qualifier value;  specify -BEFORE=delta_or_absolute_time
################################################################################
$MUPIP journal -extract=before2.mjf -before=\"$time00_abs\" -forward $mjlfiles
#check_mjf before2.mjf
#Expected result: Nothing is extracted to before2.mjf.
################################################################################
$MUPIP journal -extract=before2a_err.mjf -before=\"$time00_abs\" -backward $mjlfiles
#Return status: nothing is extracted.
################################################################################
$MUPIP journal -extract=before3.mjf -before=\"0 $delta1\" -forward $mjlfiles
check_mjf before3.mjf
#Expected result: the following is extracted to before3.mjf
#F i=1:1:10 S ^A(i)="A"_i
#F i=1:1:10 S ^B(i)="B"_i
################################################################################
$MUPIP journal -extract=before4_err.mjf -before=\"0 $delta1\" -after=\"0 $delta2\" -forward $mjlfiles
#Expected result:  JNLTMQUAL4, Time qualifier BEFORE_TIME="" is less than AFTER_TIME=""
################################################################################
$MUPIP journal -extract=since1.mjf -since=\"0 $delta0\" -before=\"0 $delta2\" -backward mumps.mjl
check_mjf since1.mjf
#Expected result: Globals ^A, ^B, ^C, ^CC are extracted to since1.mjf
################################################################################
$MUPIP journal -extract=since2.mjf -since=\"0 $delta0\" -before=\"0 $delta1\" -backward mumps.mjl
check_mjf since2.mjf
#Expected result: Globals ^A, ^B are extracted to since2.mjf
################################################################################
$MUPIP journal -extract=since3.mjf -since=\"$time0_abs\" -before=\"0 $delta2\" -backward mumps.mjl
check_mjf since3.mjf
#Expected result: Globals ^A, ^B, ^C, ^CC, are extracted to since3.mjf
################################################################################
$MUPIP journal -extract=since4_err.mjf -since=\"$time00_abs\" -before=\"0 $delta2\" -backward mumps.mjl
#Expected result: Error out because the since time precedes the first time recorded in the journal file
#Return status: GTM-E
#some other errors:
$MUPIP journal -extract=error.mjf -since=\"$time4_abs\" -before=\"0 $delta2\" -backward mumps.mjl
$MUPIP journal -extract=error.mjf -since=\"$time3_abs\" -before=\"$time2_abs\" -backward mumps.mjl
$MUPIP journal -extract=error.mjf -after=\"$time3_abs\" -before=\"$time2_abs\" -forward mumps.mjl
################################################################################
$MUPIP journal -extract=since5.mjf -since=\"$time0_abs\" -before=\"0 $delta2\" -backward mumps.mjl
check_mjf since5.mjf
#Expected result: Globals ^A, ^B, ^C, ^CC, are extracted to since5.mjf
################################################################################
#"Layek, as discussed this is not a correctness issue but an inelegance in terms of handling one region journal files." --Nars
# As per the discussion between Layek and Narayanan, this next test will not always produce the same result (sometimes it might extract some data). So it is disabled.
#
#$MUPIP journal -extract=since6.mjf -since=\"$time4_abs\" -backward mumps.mjl
#check_mjf since6.mjf
#Expected result: No data is extracted to since6.mjf  because the since time exceeds the last time recorded in the journal file
################################################################################
unset echo
cp ./save/*.dat .
$gtm_tst/com/dbcheck.csh
