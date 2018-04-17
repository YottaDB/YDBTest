#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

# ***WARNING*** Due to an unknown tcsh issue on solaris servers, if the number of lines at the top are too many,
# tcsh mishandles the unicode characters in the rest of the script. Due to this,
# a) copyright statement is not inserted
# b) The comments about this test are placed at the end
$echoline
echo " Testing BADCHSET error "
$gtm_exe/mumps -run badchset^errors
$echoline
# DLRCTOOBIG doesn't get issued at all even with older versions of GT.M, $C(>255) is just silently ignored
#echo " Testing DLRZCTOOBIG error "
#$gtm_exe/mumps -run dlrzctoobig^errors
#$echoline
echo " Testing BADCASECODE error "
$gtm_exe/mumps -run badcasecode^errors
#
$echoline
echo " Testing NONUTF8LOCALE error "
# the local_x.outs are helpful for debugging if the test behaves incorrectly.
locale > locale_1.out
$GTM
if ($status) echo "TEST-E-ERROR normal gtm direct mode failed,check locale_1.out"
if ($?LC_ALL) then
	set LC_ALL_restore=$LC_ALL # use this variable to restore the state of LC_ALL after the completion of the test
endif
#
# depending on the list of locales configured, locale -a might be considered a binary output. (on scylla currently)
# grep needs -a option to process the output as text to get the actual value instead of "Binary file (standard input) matches"
# but -a is not supported on the non-linux servers we have.
if ("Linux" == "$HOSTOS") then
	set binaryopt = "-a"
else
	set binaryopt = ""
endif
setenv  LC_ALL `locale -a | $grep $binaryopt -iE 'en_us\.utf.?8$' | $head -n 1`
#
set lc_all_save = $LC_ALL
unsetenv LC_ALL
locale > locale_2.out
$GTM
if ($status) echo "TEST-E-ERROR failure not expected as LANG is still defined,check locale_2.out"
unsetenv LANG
# do this additional step
unsetenv LC_CTYPE
# this is because LC_CTYPE is explicitly setenv'ied by the test system for unicode runs so a unsetenv of LANG doesn't remove LC_CTYPE definition
locale > locale_3.out
echo "Expected NONUTF8LOCALE because of LANG,LC_CTYPE,LC_ALL not being defined at this point"
$GTM
if !($status) echo "TEST-E-ERROR NONUTF8LOCALE failure expected since LC_TYPE is undefined but got none,check locale_3.out"
echo ""
setenv LC_ALL   $lc_all_save
locale > locale_4.out
$GTM
if ($status) echo "TEST-E-ERROR failure not expected as LC_ALL is defined, check locale_4.out"
unsetenv LC_ALL
setenv LC_CTYPE   $lc_all_save
locale > locale_5.out
$GTM
if ($status) echo "TEST-E-ERROR failure not expected as LC_TYPE is restored, check locale_5.out"
setenv LC_CTYPE some_invalid_locale # some non-UTF-8 locale not found on the system
locale >& locale_6.out
echo "Expected NONUTF8LOCALE because of LC_CTYPE points to invalid CHSET"
$GTM
if !($status) echo "TEST-E-ERROR NONUTF8LOCALE failure expected since LC_TYPE is pointing to a invalid UTF-8 encoding, check locale_6.out"
echo ""
setenv LC_CTYPE   $lc_all_save
#
# restore LC_ALL
if ($?LC_ALL_restore) then
	setenv LC_ALL $LC_ALL_restore
endif
#
$echoline
echo " Testing BOMMISMATCH error "
$gtm_exe/mumps -run bommismatch^errors
# also make sure BOM is written in the first place
set bom=`od -t x2 bommismatch.out | $tst_awk '/0000000/ {print tolower($2); exit;}'`
if ( "fffe" != "$bom" && "feff" != "$bom" ) then # cover both endianness
	echo "TEST-E-ERROR no BOM written by GT.M in bommismatch.out"
endif
#
$echoline
echo " Testing LOADINVCHSET error "
# switch to "M" CHSET
# due to a bizarre tcsh bug locale information influences the chset in GTM
# inspite of switching to "M" mode GTM will operate in UTF8 causing MUPIP extract to report incorrect rec_len information
# The work around is to not allow LC_ALL to be set to "C"
$switch_chset "M" >&! switch1.out
# NOTE :the below step is to workaround tcsh/locale issue
unsetenv LC_ALL
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << eof
s ^a="ABC"
s ^b="¡¢£¤¥¦§¨©ª«¬­"
eof
$MUPIP extract -format=GO go.out
$MUPIP extract -format=ZWR zwr.out
$gtm_tst/com/dbcheck.csh
mkdir bak1
mv mumps.dat mumps.gld bak1
# switch back to UTF-8
$switch_chset "UTF-8" >&! switch2.out
$gtm_tst/com/dbcreate.csh mumps 1
$MUPIP load -format=GO go.out >&! go.log
$MUPIP load -format=ZWR go.out >&! zwr.log
$gtm_tst/com/check_error_exist.csh go.log "LOADINVCHSET" "MUNOFINISH"
$gtm_tst/com/check_error_exist.csh zwr.log "LOADINVCHSET" "MUNOFINISH"
#
$echoline
# the source lines limit of 2048 is taken care in limits subtest
echo "Test for INDRMAXLEN limit "
$GTM << eof >&! indrmaxlen.out
set cmd="set somevar=""abcdｅｆｇｈ娃开始绔娃开"_\$\$^longstr(8146)_""""
xecute cmd
eof
#
$gtm_tst/com/check_error_exist.csh indrmaxlen.out "INDRMAXLEN"
#
$echoline
echo "Test for existing error messages with unicode characters"
#
$GTM << eof
write "some string" for x=1:1:1:1
write "The tick symbol in the error should appear at the last colon just like for the above non-multibyte string"
write "Ｓｏｍｅ ｓｔｒ Türkçe" for x=1:1:1:1
write "some string" abc
write "Ｓｏｍｅ ｓｔｒ Türkçe" abc
write "The tick symbol in the error should appear right below abc just like the above non-multibyte string"
write "sdfsdfsabcdefg" write  B
write "The tick symbol in the error should appear in the same column just like for the above non-multibyte string"
write "sdfsdfsdＡＢＣＤＥＦＧ" write  Ｂ
write "Try simple GVUNDEF error"
write ^globalsinglebyte("oneoneoneall")
write ^globalsinglebyte("ｏｎｅｏｎｅｏｎｅａｌｌ")
eof
#
$gtm_tst/com/dbcheck.csh
$echoline
echo "Testing DLRCILLEGAL error"
# The expected scenario where this could happen is when the users trying to load an extract from an M-database when switching to UTF-8 might edit the extract to have some illegal $C representations in it. This will croak with DLRCILLEGAL when we load it to a db. Note: It happens only when the change is at the subscript level of the global. If it is in the data then the error will be LOADFILERR.
#
mv mumps.dat mumps_bak.dat
mv mumps.gld mumps_bak.gld
$gtm_tst/com/dbcreate.csh mumps 1
$GTM << eof
s ^a="abc"
s ^a("abc")="this has to be changed with illegal \$c values"
eof
$MUPIP extract -format=zwr extract.zwr
$gtm_tst/com/dbcheck.csh
mkdir bak2
mv mumps.* bak2
$gtm_tst/com/dbcreate.csh mumps 1
# edit the extract
sed 's/\^a("abc")/\^a(\$C(55296)/' extract.zwr >&! modext.zwr
$MUPIP load modext.zwr >&! dlrcillegal.out
$gtm_tst/com/check_error_exist.csh dlrcillegal.out "DLRCILLEGAL" "RECLOAD"
echo "Testing WIDTHTOOSMALL error"
$GTM << eof >&! widthtoosmall.out
use \$P:(width=1)
eof
$gtm_tst/com/check_error_exist.csh widthtoosmall.out "WIDTHTOOSMALL"
$switch_chset "M" >&! switch3.out
echo "In  M mode width=1 is allowed";
# we can only check if width=1 is accepted and not error out - do not attemp to pass any commands after that
# as tcsh file is being passed to GTM so the commands that GTM read wil not be of width 1
$GTM << eof
use \$P:(width=1)
eof
#switch back to UTF-8
$switch_chset "UTF-8" >&! switch4.out
# ICUVERLT36 is issued in two scenarios -
# (a) ydb_icu_version < 3.6 : Can be tested in all platforms
# (b) non symbol-renamed libicuio.so has version < 3.6 : Can be tested only on Solaris (an unsupported platform)
echo "Testing ICUVERLT36 error - case (a)"
if ($?gtm_icu_version) then
	setenv save_icu_version $gtm_icu_version
endif
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_icu_version gtm_icu_version "3.2" # Set gtm_icu_version to a value less than 3.6
$GTM >&! icuverlt36a.out
if ($?save_icu_version) then
	setenv ydb_icu_version $save_icu_version
	setenv gtm_icu_version $save_icu_version
endif
$gtm_tst/com/check_error_exist.csh icuverlt36a.out "ICUVERLT36"
echo "END of errors"
#
$gtm_tst/com/dbcheck.csh
#
# Test different kinds of unicode introduced errors
#
##########################################################################################################
# BADCHSET      <!AD is not a valid character mapping in this context>/error/fao=2!/ansi=0
# BADCASECODE   <!AD is not a valid case conversion code>/error/fao=2!/ansi=0
# BADCHAR               <$ZCHAR(!AD) is not a valid character in the !AD encoding form>/error/fao=4!/ansi=0
# DLRCILLEGAL   <!_!AD!/!_!_!_Illegal $CHAR() value !UL>/error/fao=3!/ansi=0
# NONUTF8LOCALE	<Locale has character encoding (!AD) which is not compatible with UTF-8 character set>/error/fao=2!/ansi=0
# INVDLRCVAL    <Invalid $CHAR() value !UL>/error/fao=1!/ansi=0
# ICUSYMNOTFOUND <Symbol !AD not found in the ICU libraries. ICU needs to be built with symbol-renaming disabled or gtm_icu_version environment variable needs to be specified>
# LOADINVCHSET  <Extract file CHSET (!AD) is incompatible with gtm_chset>/error/fao=2!/ansi=0
# DLLCHSETM     <Routine !AD in library !AD was compiled with CHSET=M which is different from $ZCHSET. Recompile with CHSET=UTF-8 and re-link.>/error/fao=4!/ansi=0
# DLLCHSETUTF8  <Routine !AD in library !AD was compiled with CHSET=UTF-8 which is different from $ZCHSET. Recompile with CHSET=M and re-link.>/error/fao=4!/ansi=0
# BOMMISMATCH   <!AD Byte Order Marker found when !AD character set specified>/error/fao=4!/ansi=0
# WIDTHTOOSMALL	<WIDTH should be at least 2 when device ICHSET or OCHSET is UTF-8 or UTF-16>/error/fao=0!/ansi=0
# ICUVERLT36	<!AD !UL.!UL. ICU version greater than or equal to 3.6 should be used>/error/fao=4!/ansi=0
##########################################################################################################
# ERRORS that are taken care in other tests
# DLLCHSETM - covered in sharedlib/gtm_chset_recompile
# DLLCHSETUTF8 - covered in sharedlib/gtm_chset_recompile
# ICUSYMNOTFOUND - covered in unicode/no_ICU
# INVDLRCVAL - covered in unicode/badchar
# LOADINVCHSET (UTF-8) - covered in mupip/mu_unicode_extract_load
##########################################################################################################
