#!/usr/local/bin/tcsh -f
#=====================================================================
# THE BELOW TR MIGHT AFFECT THIS TEST
# C9G04-002786 locks and resource names with subscripts and LKE -LOCK option
#=====================================================================
# This subtest will be called from instream when the test is not submitted with replication (and also when the test is
# submitted with -unicode, in which case it can be the only subtest). i.e. even if the test was not submitted with
# -unicode, this subtest will turn it on. This way, we will not have to add a new entry in the SUITE, and still have unicode testing.
#
# override gtm_chset for this test
$switch_chset "UTF-8"
#
$gtm_tst/com/dbcreate.csh mumps
# create a routine that  lock several types of unicode subscript globals
cat << \EOF > locks.m
startjob ;
        set jmaxwait=0
        do ^job("child^locks",1,"""""")
        quit
child   ;
        write "Here in child, will lock some variables",!
        lock ^a("♚♝A♞♜")
        lock +z("ΨΈẸẪΆΨ")
        lock +^b("ڦAΨמ","ẙ۩Ÿ",2,"ĂȑƋっ")
        lock +^a($CHAR(64980,65000),"ABC","ＮＯＮ-ＧＲＡＰＨＩＣ １")
        lock +^a($CHAR(64990,65001),"DEF","ＮＯＮ-ＧＲＡＰＨＩＣ ２")
	zallocate ^zb("ڦAΨמ","ẙ۩Ÿ",2,"ĂȑƋっ")
	zallocate ^zb($CHAR(64980,65000),"ABC","ＺＡＬＬＯＣＡＴＥ ＮＯＮ-ＧＲＡＰＨＩＣ ")
        zallocate zl("ΨΈẸẪΆΨ")
	zshow "L"
        set ^childlocks=1
        for i=1:1  quit:1=$DATA(^stop)  hang 1
	kill ^stop
        write "All done!",!
        quit
badcharjob	;
        set jmaxwait=0
        do ^job("badcharchild^locks",1,"""""")
        quit
badcharchild	;
        write "Here in child, will lock some badchar variables",!
        lock +^b("bad1",$ZCHAR(199,199,299),"ＩＬＬＥＧＡＬ ＭＩＸ １")
        lock +^b("bad2",$ZCHAR(399,399,399),$ZCHAR(900,900,900),"ＩＬＬＥＧＡＬ ＭＩＸ ２")
	zallocate ^za($ZCHAR(399,399,399),$ZCHAR(900,900,900),"ＺＡＬＬＯＣＡＴＥ ＩＬＬＥＧＡＬ ＭＩＸ ")
	zshow "L"
        set ^childlocks=1
        for i=1:1  quit:1=$DATA(^stop)  hang 1
        write "All done!",!
        quit
waitjob ;
        set ^stop=1
        do wait^job
        quit
\EOF
#
echo "#lock the globals that has unicode character subscripts"
$GTM << eof
VIEW "NOBADCHAR"
do startjob^locks
for i=1:1:120 quit:1=\$DATA(^childlocks)
halt
eof
#
$echoline
echo "#Show all the locks held"
# run this section for both gtm_chset=UTF-8 and otherwise
foreach chset ( UTF-8 bla)
	setenv gtm_chset "$chset"
	$LKE show -all >&! lkeshow_$chset.out
	$tst_awk '{gsub(/PID= [0-9]* which is/,"PID= ##PID## which is");print}'  lkeshow_$chset.out >&! lkeshowall_$chset.out
end
#
$echoline
echo "with gtm_chset equal to UTF-8"
cat lkeshowall_UTF-8.out
$echoline
echo "with gtm_chset equal to bla"
diff lkeshowall_bla.out $gtm_tst/$tst/outref/lkeshowall_bla.txt >&! lkeshowall_bla.diff
if ($status) then
	echo "TEST-E-DIFF exists between lkeshowall_bla.out $gtm_tst/$tst/outref/lkeshowall_bla.txt"
else
	echo "TEST-I-PASS lke show -all test passed"
endif

# pass unicode characters to lke commands
$echoline
echo "show and clear certain existent and non-existent locks"
echo "with gtm_chset equal to $gtm_chset"
# with gtm_chset not UTF-8 at this point try show,clear on some variables and then proceed to do the whole stuffs with UTF-8
#
$LKE << lke_eof >&! lke1.out
show -lock="^a("♚♝A♞♜")"
show -lock="^a("♚♝A♞♜A")"
clear -lock="^a("♚♝A♞♜")" -nointeractive
clear -lock="^a("♚♝A♜")" -nointeractive
lke_eof
#
$tst_awk '{gsub(/PID= [0-9]* which is/,"PID= ##PID## which is");print}'  lke1.out
# get back to utf-8 setting and proceed
$echoline
setenv gtm_chset "UTF-8"
echo "#proceed with gtm_chset equal to $gtm_chset"
$LKE << lke_eof >&! lke2.out
show -lock="^b("ڦAΨמ","ẙ۩Ÿ",2,"ĂȑƋっ")"
show -lock="^b("ڦΨמ","ẙ۩Ÿ",2,"ĂȑƋっ")"
show -lock=^a(\$CHAR(65999,67999),"ABC","ＮＯＮ-ＧＲＡＰＨＩＣ １")
show -lock=^a(\$CHAR(66999,67999),"ABC","ＮＯＮ-ＧＲＡＰＨＩＣ １")
clear -lock=^b("ڦAΨמ","ẙŸ",2,"ĂȑƋっ") -nointeractive
clear -lock=^a(\$CHAR(98888,99999),"ABC","ＮＯＮ-ＧＲＡＰＨＩＣ ２") -nointeractive
show -all
clear -all -nointeractive
lke_eof
#
$tst_awk '{gsub(/PID= [0-9]* which is/,"PID= ##PID## which is");print}'  lke2.out
echo "#release the job"
$GTM << EOF
do waitjob^locks
halt
EOF

$echoline
echo "#Now do some badchar locks"
$GTM << eof >&! badchargtm.out
do badcharjob^locks
for i=1:1:120 quit:1=\$DATA(^childlocks)
halt
eof

$echoline
echo "# show and clear locks using lke. But redirect the o/p to a file and check"
$LKE << lke_eof >&! lke3.out
show -lock=^b("bad1",\$ZCHAR(199,199,299),\$ZCHAR(300,300,200),"ＩＬＬＥＧＡＬ ＭＩＸ １")
show -lock=^b("bad2",\$ZCHAR(399,399,399),\$ZCHAR(900,900,900),"ＩＬＬＥＧＡＬ ＭＩＸ ２")
clear -lock=^b("bad2",\$ZCHAR(399,399,399),\$ZCHAR(900,900,900),"ＩＬＬＥＧＡＬ ＭＩＸ ２") -nointeractive
clear -lock=^za(\$ZCHAR(399,399,399),\$ZCHAR(900,900,900),"ＺＡＬＬＯＣＡＴＥ ＩＬＬＥＧＡＬ ＭＩＸ ") -nointeractive
show -all
clear -all -nointeractive
lke_eof
#
$tst_awk '{gsub(/PID= [0-9]* which is/,"PID= ##PID## which is");print}'  lke3.out >&! badcharlke.out
$echoline
echo "# compare badcharlke.out the stored badcharlke.txt in outref"
diff badcharlke.out $gtm_tst/$tst/outref/badcharlke.txt >&! badcharlke.diff
if ($status) then
	echo "TEST-E-DIFF exists between badcharlke.out $gtm_tst/$tst/outref/badcharlke.txt"
else
	echo "TEST-I-PASS badchar test for locks passed"
endif
echo "#release the job"
$GTM <<EOF
do waitjob^locks
halt
EOF
$echoline
$gtm_tst/com/dbcheck.csh
