#!/usr/local/bin/tcsh -f
# This applies to replication only and utf-8 supported machines. pfloyd may not like this for tcsh issues
setenv gtm_repl_instance ＡＢＣＤＥ.ＦＧ
# Unsetenv gtm_custom_errros to avoid any FTOKERR/ENO2 errors (in $MUPIP set -replication below) due to the non-existence
# of mumps.repl
unsetenv gtm_custom_errors
set lcludir="αβγδεdir我能吞下玻璃而傷"
set rmtudir="ⅠⅡⅢⅣいろはにほへどちりぬるを"
set dbbase="ＡＢＣＤＥＦＧ我能吞下玻璃而傷"
\mkdir $lcludir 
cd $lcludir 
setenv gtmgbldir $dbbase.gld
source $gtm_tst/com/dbcreate_base.csh $dbbase 2 200 1000 1024 
$MUPIP set -replication=on -REG "*" >>& jnl.log
## Causes DB corruption: $sec_shell "$sec_getenv ; cd $SEC_SIDE ; \mkdir $rmtudir ; cd $rmtudir ; setenv gtmgbldir $dbbase.gld  ; source $gtm_tst/com/dbcreate_base.csh $dbbase 2 64 700 1024"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; \mkdir $rmtudir ; cd $rmtudir ; setenv gtmgbldir $dbbase.gld  ; source $gtm_tst/com/dbcreate_base.csh $dbbase 3 200 1500 2048"
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $MUPIP set -replication=on -REG '*' >>& jnl.log"
setenv portno `$sec_shell "$sec_getenv ; source $gtm_tst/com/portno_acquire.csh"`
$sec_shell "$sec_getenv ; echo $portno >&! $SEC_SIDE/portno"
$gtm_tst/com/SRC.csh "." $portno "" >>&! START.out
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $gtm_tst/com/RCVR.csh ""."" $portno "" < /dev/null "">&!"" $SEC_SIDE/START.out ; "
setenv gtm_repl_instsecondary $gtm_test_cur_sec_name
echo On Primary Change Log: $MUPIP replicate -source -changelog -log=SRCａｂｃｄｅｆｇ.log
$MUPIP replicate -source -changelog -log=SRCａｂｃｄｅｆｇ.log
$gtm_tst/com/wait_for_log.csh -log SRCａｂｃｄｅｆｇ.log -message "Change log to SRCａｂｃｄｅｆｇ.log successful" -duration 60 -waitcreation
echo On Secondary Change Log: $MUPIP replicate -receiv -changelog -log=RCVRａｂｃｄｅｆｇ.log
$sec_shell  "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $MUPIP replicate -receiv -changelog -log=RCVRａｂｃｄｅｆｇ.log; $gtm_tst/com/wait_for_log.csh -log RCVRａｂｃｄｅｆｇ.log.updproc -message 'Change log to RCVRａｂｃｄｅｆｇ.log.updproc successful' -duration 60 -waitcreation" 
echo wait for log to change...
#
$GTM << xyz
for i=1:1:10000 s ^dummy(1)=i
set ustr1="víztűrőtükörfúrógépalsches Üben von Xylophonmusik quält größeren ｉｊｋｌｍｎｏ"
set ustr2="いろはにほへど　ちりぬるをがよたれぞ　つねならむrvíztűrőtükörfúrógépalsches Üben von Xylophonmusik quält jeden größeren Zwerg ｉｊｋｌｍｎｏ"
set ^avar(ustr1,1)=1
set ^bvar(ustr1,1)=ustr2
set ^cvar(ustr1,1)=ustr1_ustr2
set ^dvar(ustr1,1)=1
h
xyz
echo On Primary Change Log Again:$MUPIP replicate -source -changelog -log=乴亐亯仑件伞佉佷.⒈⒉⒊⒋⒌⒍⒎⒏.out
$MUPIP replicate -source -changelog -log=乴亐亯仑件伞佉佷.⒈⒉⒊⒋⒌⒍⒎⒏.out
$gtm_tst/com/wait_for_log.csh -log 乴亐亯仑件伞佉佷.⒈⒉⒊⒋⒌⒍⒎⒏.out -message "Change log to 乴亐亯仑件伞佉佷.⒈⒉⒊⒋⒌⒍⒎⒏.out successful" -duration 60 -waitcreation
echo On Secondary Change Log Again: $MUPIP replicate -receiv -changelog -log=蝉休露满枝永怀当此节.①②③④⑤⑥⑦⑧.out
$sec_shell  "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $MUPIP replicate -receiv -changelog -log=蝉休露满枝永怀当此节.①②③④⑤⑥⑦⑧.out; $gtm_tst/com/wait_for_log.csh -log 蝉休露满枝永怀当此节.①②③④⑤⑥⑦⑧.out.updproc -message 'Change log to 蝉休露满枝永怀当此节.①②③④⑤⑥⑦⑧.out.updproc successful' -duration 60 -waitcreation"
echo wait for log to change...
$GTM << EOF
for i=1:1:10000 s ^dummy(2)=i
set ustr1="víztűrőtükörfúrógépalsches Üben von Xylophonmusik quält größeren ｉｊｋｌｍｎｏ"
set ustr2="いろはにほへど　ちりぬるをがよたれぞ　つねならむrvíztűrőtükörfúrógépalsches Üben von Xylophonmusik quält jeden größeren Zwerg ｉｊｋｌｍｎｏ"
set ^avar(ustr1,2)=2
set ^bvar(ustr1,2)=ustr2
set ^cvar(ustr1,2)=ustr1_ustr2
set ^dvar(ustr1,2)=\$j(ustr1,500)
h
EOF
sleep 4
#
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $gtm_tst/com/RCVR_SHUT.csh ""on"" < /dev/null >>&! $SEC_SIDE/SHUT.out"
$gtm_tst/com/SRC_SHUT.csh "on" < /dev/null >>&! $PRI_SIDE/SHUT.out
$gtm_tst/com/db_extract.csh pri.glo
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $gtm_tst/com/db_extract.csh ../sec.glo"
$gtm_tst/com/dbcheck_base.csh
$sec_shell "$sec_getenv ; cd $SEC_SIDE ; cd $rmtudir ; $gtm_tst/com/dbcheck_base.csh"
#
$gtm_tst/com/portno_release.csh
