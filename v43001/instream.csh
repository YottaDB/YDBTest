# for stuff fixed for V43001

echo "v43001 test starts..."
# this test has explicit mupip creates, so let's not do anything that will have to be repeated at every mupip create
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
#
# zgbldir               : C9710-000276 $zgbldir related change
# zhelp	     [Mohammad] : C9710-000276 ZHELP generates inappropriate error message 
# patcode               : C9612-000150 Patcode other than A,C,E,L,N,P,U causes syntax error in mumps program 
# longrecord            : D9C03-002060 Writing long records to batch log file yields RMS-F-RSZ invalid record size
# system_isv            : C9B12-001868 $SYSTEM setup does not work as advertised
# zdate_form            : C9C02-001928 Provide a means of formatting 21st century as 4 digits as default 
# job interrupt [Steve] : C9A02-001421
# seq_format            : C9902-000832 Lost transactions should be in a Unified JnlSeqno format.
# d9c022044             : if <false> <bad ref> related
# zjob         [Malli]  : C9904-001023 Job command should return PID of newly created process
# set $extract [Malli]  : S9C05-002113 SET $EXTRACT reports GTM-E-UNIMPLOP
# C9A01001386  [Nergis] : change online backup to not replace existing backup by default
# mu_disallow  [Nergis] : is nixed by Narayanan and moved to "mupip_disallow" subtest of "disallow" test 
#
if ($?test_replic) then
	setenv subtest_list "seq_format"
else
	setenv subtest_list "C9A01001386 c001950 c001953 zgbldir zhelp patcode longrecord system_isv zdate_form"
	setenv subtest_list "$subtest_list C9A02001421 d9c022044 C9606-000085 zjob mupip_cli gtm_zlink setex"
endif
# filter out subtests that cannot pass with MM
# mupip_cli	Tests both before and nobefore image journaling
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "mupip_cli"
endif
$gtm_tst/com/submit_subtest.csh
echo "v43001 test DONE."
