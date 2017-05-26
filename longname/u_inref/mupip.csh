#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# the output of this test relies on transaction numbers, so let's not do anything that might change the TN
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
setenv gtm_test_spanreg 0	# The test has mostly single key globals and has a lot of integ output.
# 'go' format is not supported in UTF-8 mode
# Since the intent of the subtest is explicitly check extract in all the three formats, it is forced to run in M mode
$switch_chset M >&! switch_chset.out

# disable random 4-byte collation header in DT leaf block since this test output is sensitive to DT leaf block layout
setenv gtm_dirtree_collhdr_always 1

set verbose
$gtm_tst/com/dbcreate.csh mumps 3 200
$gtm_tst/com/jnl_on.csh
$GTM << xxx
set local=0
do set^lotsvar
do ver^lotsvar
halt
xxx
###############################
# globals set
#. MUPIP EXTRACT file_spec -select=global-name
echo "MUPIP EXTRACT file_spec -select=global-name"
# use longnames instead of the global names used below
$MUPIP extract x1.ext -select="^%8ZQHypg,^A1BbLlVv,^VD6z2vYrUnQjMfIbE7A3wZsVoR,^pkmoq,^zxvtrpnljhfdb97,^x:^z" >&! x1.out
$gtm_tst/com/grepfile.csh "\^%8ZQHypg[=( ]" x1.ext 1
$gtm_tst/com/grepfile.csh "\^xVBhXDjZFl1Hn3Jp5Lr7Nt9Pv[=( ]" x1.ext 1
$gtm_tst/com/grepfile.csh "\^BLFztnhb[=( ]" x1.ext 0
echo ""
$MUPIP extract x2.ext -select="^VD6z2vYrUnQjMfIbE7A3wZsVoR,^B:^D,^HdKhOl*" >&! x2.out
$gtm_tst/com/grepfile.csh "\^VD6z2vYrUnQjMfIbE7A3wZsVoR[=( ]" x2.ext 1
$gtm_tst/com/grepfile.csh "\^CdxRbvP9tN7rL5pJ3nH1lFZjDXhB[=( ]" x2.ext 1
$gtm_tst/com/grepfile.csh "\^EQV05afkpuzEJOTY38dinsxCHMR[=( ]" x2.ext 0
echo ""
$MUPIP extract x3.ext -select="^KA:^ka" >&! x3.out
$gtm_tst/com/grepfile.csh "\^KlqvAFKP[=( ]" x3.ext 1
$gtm_tst/com/grepfile.csh "\^kUDm5OxgZIraTCl4NwfYHq9SB[=( ]" x3.ext 1
$gtm_tst/com/grepfile.csh "\^l2Hm1Gl0[=( ]" x3.ext 0
echo ""
$MUPIP extract x4.ext -freeze -select="^%8ZQHypg,^A1BbLlVv,^VD6z2vYrUnQjMfIbE7A3wZsVoR,^pkmoq,^zxvtrpnljhfdb97,^x:^z" >&! x4.out
$gtm_tst/com/grepfile.csh "\^%8ZQHypg[=( ]" x4.ext 1
$gtm_tst/com/grepfile.csh "\^xVBhXDjZFl1Hn3Jp5Lr7Nt9Pv[=( ]" x4.ext 1
$gtm_tst/com/grepfile.csh "\^BLFztnhb[=( ]" x4.ext 0
echo ""
$MUPIP extract x5.ext -freeze -select="^VD6z2vYrUnQjMfIbE7A3wZsVoR,^B:^D,^HdKhOl*" >&! x5.out
$gtm_tst/com/grepfile.csh "\^VD6z2vYrUnQjMfIbE7A3wZsVoR[=( ]" x5.ext 1
$gtm_tst/com/grepfile.csh "\^CdxRbvP9tN7rL5pJ3nH1lFZjDXhB[=( ]" x5.ext 1
$gtm_tst/com/grepfile.csh "\^EQV05afkpuzEJOTY38dinsxCHMR[=( ]" x5.ext 0
echo ""
# This is to test trunction behaviour if the name given is more than 31 chars long
# Due to a known bug in mupip extract, mupip does the truncation right, but reports the global name longer than 31 chars
# Change the reference file once the bug is fixed
$MUPIP extract x6.ext -select="^A91TLDvnf7ZRJBtld5XPHzrjb3VNFxpa"
cat x6.ext
echo ""

# MUPIP EXTRACT file_spec -format=GO -select=global-name
$MUPIP extract xgo1.ext -format=GO -select="^%8ZQHypg,^A1BbLlVv,^VD6z2vYrUnQjMfIbE7A3wZsVoR,^pkmoq,^zxvtrpnljhfdb97,^x:^z" >&! xgo1.out
$gtm_tst/com/grepfile.csh "\^%8ZQHypg[=( ]" xgo1.ext 1
$gtm_tst/com/grepfile.csh "\^xVBhXDjZFl1Hn3Jp5Lr7Nt9Pv" xgo1.ext 1
$gtm_tst/com/grepfile.csh "\^BLFztnhb[=( ]" xgo1.ext 0
echo ""
$MUPIP extract xgo2.ext -format=GO -select="^VD6z2vYrUnQjMfIbE7A3wZsVoR,^B:^D,^HdKhOl*" >&! xgo2.out
$gtm_tst/com/grepfile.csh "\^VD6z2vYrUnQjMfIbE7A3wZsVoR[=( ]" xgo2.ext 1
$gtm_tst/com/grepfile.csh "\^CdxRbvP9tN7rL5pJ3nH1lFZjDXhB[=( ]" xgo2.ext 1
$gtm_tst/com/grepfile.csh "\^EQV05afkpuzEJOTY38dinsxCHMR[=( ]" xgo2.ext 0
echo ""
$MUPIP extract xgo3.ext -format=GO -select="^KA:^ka" >&! xgo3.out
$gtm_tst/com/grepfile.csh "\^KlqvAFKP[=( ]" xgo3.ext 1
$gtm_tst/com/grepfile.csh "\^kUDm5OxgZIraTCl4NwfYHq9SB[=( ]" xgo3.ext 1
$gtm_tst/com/grepfile.csh "\^l2Hm1Gl0[=( ]" xgo3.ext 0
echo ""
# MUPIP EXTRACT file_spec -format=BIN -select=global-name
$MUPIP extract xbin1.ext -format=BIN -select="^%8ZQHypg,^A1BbLlVv,^VD6z2vYrUnQjMfIbE7A3wZsVoR,^pkmoq,^zxvtrpnljhfdb97,^x:^z" >&! xbin1.out
$MUPIP extract xbin2.ext -format=BIN -select="^VD6z2vYrUnQjMfIbE7A3wZsVoR,^B:^D,^HdKhOl*" >&! xbin2.out
$MUPIP extract xbin3.ext -format=BIN -select="^KA:^ka" >&! xbin3.out
# MUPIP EXTRACT file_spec -format=ZWR -select=global-name
echo ""
$MUPIP extract xzwr1.ext -format=ZWR -select="^%8ZQHypg,^A1BbLlVv,^VD6z2vYrUnQjMfIbE7A3wZsVoR,^pkmoq,^zxvtrpnljhfdb97,^x:^z" >&! xzwr1.out
$gtm_tst/com/grepfile.csh "\^%8ZQHypg[=( ]" xzwr1.ext 1
$gtm_tst/com/grepfile.csh "\^xVBhXDjZFl1Hn3Jp5Lr7Nt9Pv[=( ]" xzwr1.ext 1
$gtm_tst/com/grepfile.csh "\^BLFztnhb[=( ]" xzwr1.ext 0
echo ""
$MUPIP extract xzwr2.ext -format=ZWR -select="^VD6z2vYrUnQjMfIbE7A3wZsVoR,^B:^D,^HdKhOl*" >&! xzwr2.out
$gtm_tst/com/grepfile.csh "\^VD6z2vYrUnQjMfIbE7A3wZsVoR[=( ]" xzwr2.ext 1
$gtm_tst/com/grepfile.csh "\^CdxRbvP9tN7rL5pJ3nH1lFZjDXhB[=( ]" xzwr2.ext 1
$gtm_tst/com/grepfile.csh "\^EQV05afkpuzEJOTY38dinsxCHMR[=( ]" xzwr2.ext 0
echo ""
$MUPIP extract xzwr3.ext -format=ZWR -select="^KA:^ka" >&! xzwr3.out
$gtm_tst/com/grepfile.csh "\^KlqvAFKP[=( ]" xzwr3.ext 1
$gtm_tst/com/grepfile.csh "\^kUDm5OxgZIraTCl4NwfYHq9SB[=( ]" xzwr3.ext 1
$gtm_tst/com/grepfile.csh "\^l2Hm1Gl0[=( ]" xzwr3.ext 0
echo ""
echo ""


#. MUPIP INTEG file_spec  -subscript=subscript
echo "MUPIP INTEG file_spec -subscript=subscript"
$MUPIP integ mumps.dat -subscript="^A91TLDvnf7ZRJBtld5XPHzrjb3VNFxp"
# should be empty, as there are 3 regions, and ^A goes to a.dat
$MUPIP integ mumps.dat -subscript="^zupkfa50VQLGBwrmhc72XSNIDyt"
$MUPIP integ mumps.dat -subscript="^IU8:^i4gsEQ2eqCO0coAMYamyKW8kwIU6iu"
$MUPIP integ -reg "*" -subscript="^Rr1BbLlVv5FfPpZz9JjTt3Dd" >&! integ_reg_star_1.out
\sort integ_reg_star_1.out
# the following command spans multiple regions, so let's sort it's output to have the same order everytime
$MUPIP integ -reg "*" -subscript="^AIzqh8ZQ:^KSJAri90R" >&! integ_reg_star_2.out
\sort integ_reg_star_2.out
$MUPIP integ mumps.dat -full -subscript="^SCEGIKMOQSUWY02468acegik"
$MUPIP integ mumps.dat -full -subscript="^SCEGIKMOQSUWY02468acegik7"
$MUPIP integ mumps.dat -full -subscript="^SE0mI4qM8uQcyUgCYkG2oK6sOawSeAW:^SSkMeG8A2uWoQiKcE6y0sUmOgI"
echo ""
echo ""

#. MUPIP REORG  -select=global-name-list
echo "MUPIP REORG -select/exclude=global-name-list"
$MUPIP reorg -select="^A91,^CoK6sOawSeAWiE0mI4qM8uQcyUgCYk,^MveXGp8R,^bSIyoe4UKAqg6WMCsi8YOEuka0Q,^%0sU" >>&! select_reorg_1.out
$grep "Global:" select_reorg_1.out
$gtm_tst/com/check_error_exist.csh select_reorg_1.out "NOSELECT"
$MUPIP reorg -select="^IxN3jzP5lBR7nDT9,^bVGrcXIt01234,^LEpaVGrcXIteZKvg1Mxi3Ozk5QBm7SD,^LEpaVGrcXIteZKvg1Mxi3Ozk5QBm7SD01" >>&! select_reorg_2.out
$grep "Global:" select_reorg_2.out
$MUPIP reorg -select="^GvGR2doz:^HC" >>&! select_reorg_3.out
$grep "Global:" select_reorg_3.out
$MUPIP reorg -select="^a93XRLFz,^aP9tN7rL5pJ3nH1lFZjDXhBVfzTdxR,^A91TLDvn,^A91TLDvnf7ZRJBtld5XPHzrjb3VNFxp" >>&! select_reorg_4.out
$grep "Global:" select_reorg_4.out
$MUPIP reorg -select="^a2345678:^b2345678,^a234567890123456789012345678901:^b234567890123456789012345678901" >>&! select_reorg_5.out
$grep "Global:" select_reorg_5.out
$MUPIP reorg -select="^ZN*" >>&! select_reorg_6.out
$grep "Global:" select_reorg_6.out
$MUPIP reorg -select="^%isCMW6gqAKU4eoy*" >>&! select_reorg_7.out
$grep "Global:" select_reorg_7.out
#. MUPIP REORG -exclude =global-name-list
$MUPIP reorg  -exclude="^Abva,^CdxRa,^MnH1lF,^bDXhBVfzTa,^AbvP9tN7rL5pJ3nH1lFZjDXhBVfzU,^H9tN7rL5pJ3nH1lFZjDXhBVfzTdxRbV" >>&! exclude_reorg_1.out
$grep "NOEXCLUDE" exclude_reorg_1.out
$MUPIP reorg  -exclude="^bVGrcXIt,^a4gsEQ2e:^a93XRLFz,^bVGrcXIt01234,^LEpaVGrcXIteZKvg1Mxi3Ozk5QBm7SD,^LEpaVGrcXIteZKvg1Mxi3Ozk5QBm7SD01" >>&! exclude_reorg_2.out
$grep  'bVGrcXIt[$ ]' exclude_reorg_2.out
$grep  'a4g[$ ]' exclude_reorg_2.out
$gtm_tst/com/check_error_exist.csh exclude_reorg_2.out "EXCLUDEREORG"  "REORGINC"

$MUPIP reorg -exclude="^H9tN7rL5pJ3nH1lFZjDXhBVfzTdxRbv:^a90RIzqh8ZQHypg7YPGxof6XOFwne5W" >>&! exclude_reorg_3.out
$gtm_tst/com/check_error_exist.csh exclude_reorg_3.out "EXCLUDEREORG"  "REORGINC"

$MUPIP reorg -exclude="^Z8isCMW7*" >>&! exclude_reorg_4.out
$grep "NOEXCLUDE" exclude_reorg_4.out
$MUPIP reorg -exclude="^%jd71VPJD*" >>&! exclude_reorg_5.out
$grep 'Global: %jd71VPJ[$ ]' exclude_reorg_5.out
$gtm_tst/com/check_error_exist.csh exclude_reorg_5.out "EXCLUDEREORG"  "REORGINC"
echo ""
echo ""

#. MUPIP JOURNAL -forw -global=global-name-list mumps.mjl
echo "MUPIP JOURNAL -forward -global=global-name-list mumps.mjl"
$MUPIP journal -show -forw -global="^e31ZXVTR,^zxvtrpnljhfdb97,^db97531ZXVTRPNLJHFDBzxvtrpnljh" mumps.mjl
$MUPIP journal -extract=extract1.mjf -forw -global="(^e31ZXVTR,^zxvtrpnljhfdb97,^db97531ZXVTRPNLJHFDBzxvtrpnljh,^B:^E)" mumps.mjl
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' extract1.mjf
$MUPIP journal -extract=extract2.mjf -forw -global="(^brQfE3sRgF4tShG5uTiH6vUjI7wVk,^b,^BL6rM7sN8tO9uPavQbwRcxSdyTe)" b.mjl
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' extract2.mjf
$MUPIP journal -extract=extract3.mjf -forw -global="(^ZN*)" mumps.mjl
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' extract3.mjf
$MUPIP journal -extract=extract4.mjf -forw -global="^A" mumps.mjl
$tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' extract4.mjf

unset verbose
echo ""
echo ""
echo "Test long region names in MUPIP commands"
$gtm_tst/com/backup_dbjnl.csh mupip1 "*.dat *.gld *.mjl* *.mjf*" mv
endif
# create the default gld and dat files
$GDE <<gde_end
   change -region default -key_size=200
   exit
gde_end
$MUPIP create
foreach iter (3 5 15 25 30 31)
   set reg="A"
   set names = ""
   @ inner = 2
   while ($inner <= $iter)
	@ num = $inner % 10
	set reg = "$reg""$num"
	set names = "$names""A"
	@ inner = $inner + 1
   end
   setenv gbl "^$names"
   set names = "$names""*"
$GDE << gde_end
   add -name $names -reg=$reg
   add -reg $reg -dyn=$reg -key_size=200
   add -seg $reg -file=$reg.dat
   exit
gde_end
# mupip commands
   $MUPIP create -region=$reg
   $MUPIP extend $reg
   $MUPIP freeze -off $reg >& freeze_$reg.out
   $MUPIP set -journal="on,enable,before" -reg $reg
   $GTM << gtm_end
	set gbl=\$ztrnlnm("gbl")
        set @gbl=1
        set gbl=gbl_"b"
        set @gbl=2
        halt
gtm_end
   $MUPIP journal -extract=$reg.mjf -forw $reg.mjl
   $tst_awk '{n=split($0,f,"\\");if (f[1]=="05") print f[n]}' $reg.mjf
   $MUPIP integ -reg $reg
   $MUPIP rundown -reg $reg
   $MUPIP backup $reg $reg.bak
echo ""
echo ""
end
# checking 32 and 64 region names. GTM shoud error but not explode
$gtm_exe/mumps -run GDE << gde_end
        add -name q -reg=regionasaverylongnametotest89012
        add -name q -reg=regionasaverylongnametotest8901234567890123456789012345678901234
        quit
gde_end

#checking the MUPIP EXTRACT file_spec -format=BIN -select=global-name
$MUPIP load -format=binary xbin2.ext
$MUPIP extract xgo4_from_xbin2.ext -format=GO -select="^VD6z2vYrUnQjMfIbE7A3wZsVoR,^B:^D,^HdKhOl*" >&! xgo4_from_xbin2.out
$gtm_tst/com/grepfile.csh "\^VD6z2vYrUnQjMfIbE7A3wZsVoR[=( ]" xgo4_from_xbin2.ext 1
$gtm_tst/com/grepfile.csh "\^CdxRbvP9tN7rL5pJ3nH1lFZjDXhB[=( ]" xgo4_from_xbin2.ext 1
$gtm_tst/com/grepfile.csh "\^EQV05afkpuzEJOTY38dinsxCHMR[=( ]" xgo4_from_xbin2.ext 0

$gtm_tst/com/dbcheck.csh -extract
