#!/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
set backslash_quote
set echo
set verbose

set verno = "V999_R999"

rm -rf /Distrib/YottaDB/$verno
mkdir -p /Distrib/YottaDB/$verno
cd /Distrib/YottaDB/$verno

if ( -f /YDB/CMakeLists.txt ) then
  cp -r /YDB/. /Distrib/YottaDB/$verno
else
  git clone --depth 1 https://gitlab.com/YottaDB/DB/YDB.git .
endif


# Edit sr_linux/release_name.h to reflect V9.9-x version name in GT.M and YottaDB versions
#
foreach file (sr_*/release_name.h)
	# ------------------------------------
	# a) Fix GT.M version Vx.x-xxx
	#
	# The format of the release_name.h file could be one of the below two choices
	#	#define GTM_RELEASE_NAME 	"GT.M V6.3-002 Linux x86_64"
	#	#define	GTM_ZVERSION		"V6.3-002"
	# Handle both here.
	grep GTM_ZVERSION $file >& /dev/null
	if (0 == $status) then
		# Change below line
		#	#define	GTM_ZVERSION	"V6.3-002"
		set gtmver = `grep "GTM_ZVERSION" $file | head -1 | awk -F\\" '{print $2}'`
	else
		# Change below line
		#	#define GTM_RELEASE_NAME 	"GT.M V6.3-002 Linux x86_64"
		set gtmver = `grep "#define.*GTM_RELEASE_NAME" $file | head -1 | awk '{print $4}'`
	endif
	# If input is V998_R100, make output as V9.9-8 (impossible $zversion #)
	set v9ver = `echo $verno | cut -d_ -f1`	# if input is V998_R100, get V998 out first
	set majorver = `echo $v9ver | cut -b1,2`
	set minorver = `echo $v9ver | cut -b3`
	set restofver = `echo $v9ver | cut -b4-`
	set newver = "$majorver.$minorver-$restofver"
	perl -p -i -e 's/'$gtmver'/'$newver'/g' $file

	# ------------------------------------
	# b) Fix YottaDB release r#.##
	#
	# The format of the release_name.h file could be one of the below two choices
	#	#define YDB_RELEASE_NAME        "YottaDB r1.00 Linux x86_64"
	#	#define YDB_ZYRELEASE   "r1.10"
	# Handle both here.
	grep YDB_ZYRELEASE $file >& /dev/null
	if (0 == $status) then
		# Change below line
		#	#define YDB_ZYRELEASE   "r1.10"
		set ydbver = `grep "YDB_ZYRELEASE" $file | head -1 | awk -F\\" '{print $2}'`
	else
		# Change below line
		#	#define YDB_RELEASE_NAME        "YottaDB r1.00 Linux x86_64"
		set ydbver = `grep "#define.*YDB_RELEASE_NAME" $file | head -1 | awk '{print $4}'`
	endif
	if ("" != "$ydbver") then
		# If input is V998_R100, make output as r998 (impossible $zyrelease #)
		set v9ver = `echo $verno | cut -d_ -f1`	# if input is V998_R100, get V998 out first
		set restofver = `echo $v9ver | cut -b2-`
		set newver = "r${restofver}"
		perl -p -i -e 's/'$ydbver'/'$newver'/g' $file
	endif

	cat $file
end

mkdir -p $gtm_root/$verno
rm -rf $gtm_root/$verno/*

mkdir -p /Distrib/YottaDB/$verno/dbg
cd /Distrib/YottaDB/$verno/dbg
cmake -Wno-dev -D CMAKE_BUILD_TYPE=Debug -D CMAKE_INSTALL_PREFIX:PATH=$PWD ..
make -j `getconf _NPROCESSORS_ONLN` install
pushd yottadb_r*
./ydbinstall --installdir=$gtm_root/$verno/dbg --utf8 default --keep-obj --ucaseonly-utils --prompt-for-group
popd
mkdir $gtm_root/$verno/dbg/obj
find . -name '*.a' -exec cp {} $gtm_root/$verno/dbg/obj \;
mkdir -p $gtm_root/$verno/tools

cd /Distrib/YottaDB/$verno
cp sr_unix/*.awk $gtm_root/$verno/tools
cp sr_unix/*.csh $gtm_root/$verno/tools
cp sr_linux/*.csh $gtm_root/$verno/tools
cp $gtm_root/$verno/dbg/custom_errors_sample.txt $gtm_root/$verno/tools
rm -f $gtm_root/$verno/tools/setactive{,1}.csh

set machtype=`uname -m`
foreach ext (c s msg h si)
        if (($ext == "h") || ($ext == "si")) then
                set dir = "inc"
        else
                set dir = "src"
        endif
				mkdir -p $gtm_ver/$dir
        cp -pa sr_port/*.$ext $gtm_ver/$dir/
        cp -pa sr_port_cm/*.$ext $gtm_ver/$dir/
        cp -pa sr_unix/*.$ext $gtm_ver/$dir/
        cp -pa sr_unix_cm/*.$ext $gtm_ver/$dir/
        cp -pa sr_unix_gnp/*.$ext $gtm_ver/$dir/
        if (${machtype} == "x86_64") then
                cp -pa sr_x86_regs/*.$ext $gtm_ver/$dir/
        endif
        cp -pa sr_${machtype}/*.$ext $gtm_ver/$dir/
        cp -pa sr_linux/*.$ext $gtm_ver/$dir/
end

# Install gtmcrypt plugin
setenv ydb_dist /usr/library/$verno/dbg
mkdir /tmp/plugin-build && cd /tmp/plugin-build
git clone https://gitlab.com/YottaDB/Util/YDBEncrypt.git .
make && make install && make clean
find $ydb_dist/plugin -type f -exec chown root:root {} +
cd -
rm -r /tmp/plugin-build
