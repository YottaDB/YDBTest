#!/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021-2024 YottaDB LLC and/or its subsidiaries.	#
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

if (! $?verno ) set verno = "V999_R999"
if (! $?gtm_root ) set gtm_root = "/usr/library"
set gtm_ver = "$gtm_root/$verno"

if ( $?work_dir ) then
	mkdir -p /Distrib/YottaDB/$verno
	rsync -arv --delete $work_dir/YDB/ /Distrib/YottaDB/$verno/
endif
cd /Distrib/YottaDB/$verno

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
		set gtmver = `grep "GTM_ZVERSION" $file | head -1 | awk '-F"' '{print $2}'`
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
	perl -p -i -e "s/$gtmver/$newver/g" $file

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
		set ydbver = `grep "YDB_ZYRELEASE" $file | head -1 | awk '-F"' '{print $2}'`
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
		perl -p -i -e "s/$ydbver/$newver/g" $file
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
./ydbinstall --installdir=$gtm_root/$verno/dbg --utf8 --keep-obj --ucaseonly-utils --prompt-for-group
popd
mkdir -p $gtm_root/$verno/dbg/obj
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

# TODO: All the plugin installs are re-installed in the YottaDB pipeline.
# The pipeline can be potentially a tiny bit faster if we can avoid that.

# Install gtmcrypt plugin
setenv ydb_dist /usr/library/$verno/dbg
mkdir -p /tmp/plugin-build && cd /tmp/plugin-build
git clone https://gitlab.com/YottaDB/Util/YDBEncrypt.git .
setenv ydb_icu_version `pkg-config --modversion icu-io`
make && make install && make clean
find $ydb_dist/plugin -type f -exec chown root:root {} +
cd -
rm -rf /tmp/plugin-build

# Install GTMJI plugin
wget https://sourceforge.net/projects/fis-gtm/files/Plugins/GTMJI/1.0.4/ji_plugin_1.0.4.tar.gz
tar xzf ji_plugin_1.0.4.tar.gz
cd ji_plugin_1.0.4
# The make step below needs JAVA_HOME and JAVA_SO_HOME env vars set appropriately so set that up first using "set_java_paths.csh"
# But before that set up "tst_awk" and "HOSTOS" env var so "set_java_paths.csh" can work without errors.
setenv tst_awk gawk	# needed for "set_java_paths.csh"
if ( $?work_dir ) then
	set java_path_script = $work_dir/YDBTest/com/set_java_paths.csh
else
	set java_path_script = /usr/library/gtm_test/set_java_paths.csh
endif
cp $java_path_script .
setenv HOSTOS `uname -s`
source set_java_paths.csh
make install && make clean
cd ..
rm ji_plugin_1.0.4.tar.gz

# Install Posix Plugin
mkdir -p /tmp/plugin-build/posix
mkdir -p /tmp/plugin-build/posix-build
git clone https://gitlab.com/YottaDB/Util/YDBPosix.git /tmp/plugin-build/posix
cd /tmp/plugin-build/posix-build
cmake /tmp/plugin-build/posix && make && make install
cd -
rm -rf /tmp/plugin-build
