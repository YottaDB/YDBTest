#!/usr/local/bin/tcsh -f
#################################################
#Send the directory for the journal files as $1
#So that this script can be used for both primary and secondary
#$1 is  the directory name for the journal files
# if $2 is -replic=on , it will turn replication on, too so that the journal files will not be switched when replication is turned on.

# Support for replication to run with NOBEFORE_IMAGE started only at V52001. Therefore if the test is run for an
# older version, set BEFORE_IMAGE unconditionally (even if test was started with -jnl nobefore). It is ok to overwrite
# the environment variable "tst_jnl_str" unconditionally to correspond to BEFORE-IMAGE as we expect the caller to
# NOT do a source of this script (thereby ensuring this script does not pollute the environment variable space of caller).
set gtmverno = $gtm_exe:h:t
set majorver = `echo $gtmverno | cut -c2-3`
set minorver = `echo $gtmverno | cut -c4-7`
if ((52 > $majorver) || (52 == $majorver) && ($minorver =~ 000*)) then
	echo "Version is older than V52001. Setting environment variable tst_jnl_str unconditionally to BEFORE-IMAGE" >>&! jnl.log
	source $gtm_tst/com/gtm_test_setbeforeimage.csh
endif

# do not create journal files at /*.mjl if $1 is null, use . then
set jnldir = "$1"
if ("$jnldir" == "") set jnldir = "."
 
if (("$2" != "-replic=on")&&("$2" != "")) then
 echo "Arguments not understood $2"
 exit
endif

setenv GDE "$gtm_exe/mumps -run GDE"
echo GDE is $GDE >>&! jnl.log
$GDE << GDE_EOF>&! gde.out
show -map
quit
GDE_EOF

echo "####################################################################" >>&! jnl.log
date >>&! jnl.log
echo "--------------------" >>&! jnl.log
echo "JOURNAL OPTIONS: $tst_jnl_str" >>&! jnl.log
# ':' is a sign of GT.CM region (oscar:/testarea4/...)
foreach x (`$grep -v "GDE" gde.out | $tst_awk -f $gtm_tst/com/v4gde_jnl_on.awk | grep -v ":" | $tst_awk -F. '{print $1}' | sort -u`)
echo File $x.dat "---> "journal file $jnldir/${x}.mjl >>&! jnl.log
echo $MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}.mjl $2 >>&! jnl.log
$MUPIP set -file ${x}.dat ${tst_jnl_str},file=$jnldir/${x}.mjl $2 >>&! jnl.log
end
