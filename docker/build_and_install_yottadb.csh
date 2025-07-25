#!/bin/tcsh -e
#################################################################
#								#
# Copyright (c) 2021-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Syntax: docker/build_and_install_yottadb.csh <folder name in /usr/library/> <git tag in YDB> <dbg/pro>
# If /Distrib/YottaDB/V999_R999/ is passed into the file system, then we use that as the source rather than /Distrib/YottaDB
set backslash_quote
set echo
set verbose

if ( $1 != "") set verno = $1
if ( $2 != "") set git_tag = $2
if ( $3 != "") set dbgpro = $3
if ( $4 != "") set mrbranch = $4

if (! $?verno ) set verno = "V999_R999"
if (! $?git_tag ) set git_tag = "master"
if (! $?gtm_root ) set gtm_root = "/usr/library"
if (! $?dbgpro ) set dbgpro = "dbg"

set gtm_ver = "$gtm_root/$verno"
set is_gtm = 0

if ( "$git_tag" =~ "V*" ) set is_gtm = 1

# Don't compile GT.M on aarch64
if ( (`uname -m` == "aarch64") && $is_gtm ) exit 0

if ( $?work_dir ) then
	mkdir -p /Distrib/YottaDB/
	rsync -arv --delete $work_dir/YDB/ /Distrib/YottaDB/$verno/
endif

if ( -d /Distrib/YottaDB/V999_R999 ) then
	# Directory /Distrib/YottaDB/V999_R999/ is created in the YDB pipeline as an new layer on the ydbtest image
	set source_dir = "/Distrib/YottaDB/V999_R999"
else
	# We only have one source tree; we checkout a different tag if necessary and use that to build
	set source_dir = "/Distrib/YottaDB"
	pushd /Distrib/YottaDB/

	# Discard sr_*/release_name.h changes from a previous run
	git checkout .

	if ( $?mrbranch ) then
		# We are testing against a specific MR branch
		git fetch origin merge-requests/${mrbranch}/head:mr-${mrbranch}
		git checkout mr-${mrbranch}
	else
		git checkout $git_tag
	endif
	# Remove "-ggdb3" from CMAKE_ASM_FLAGS_DEBUG else AARCH64 build fails (see commit f88b9698 for more details)
	# The below sed command is structured to work for r1.38 (pre f88b9698) or r2.00 (post f88b9698) so we do not
	# need to check if the git tag is less than or equal to r1.38 in order to do this removal.
	sed -i '/-ggdb3/d' sr_linux/platform.cmake
	popd
endif

cd $source_dir

# Edit sr_linux/release_name.h to reflect V9.9-x version name in GT.M and YottaDB versions
# But only for master branch; (leave tags alone)
if ( "$git_tag" == "master" ) then
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
endif

mkdir -p $gtm_root/$verno

# We need to set nonomatch here bacause we're not sure that
# $gtm_root/$verno have anything inside already just we want to clean it first
# then we will unset nonomatch after this line is done
set nonomatch
rm -rf $gtm_root/$verno/$dbgpro/*
unset nonomatch

mkdir -p $source_dir/$dbgpro
cd $source_dir/$dbgpro
if ( "$dbgpro" == "dbg" ) then
	cmake -Wno-dev -D CMAKE_BUILD_TYPE=Debug -D CMAKE_INSTALL_PREFIX:PATH=$PWD $source_dir/
else
	cmake -Wno-dev -D CMAKE_BUILD_TYPE=RelWithDebInfo -D CMAKE_INSTALL_PREFIX:PATH=$PWD $source_dir/
endif
make -j `getconf _NPROCESSORS_ONLN` install
if ( $is_gtm ) then
	pushd lib/*/*
		if ($verno =~ "*V7*") then
			# the --utf8 option does not accept an ICU version in GT.M V7.0-000 or later
			./gtminstall --installdir=$gtm_root/$verno/$dbgpro --utf8 --keep-obj --ucaseonly-utils --prompt-for-group
		else
			./gtminstall --installdir=$gtm_root/$verno/$dbgpro --utf8 default --keep-obj --ucaseonly-utils --prompt-for-group
		endif
	popd
else
	pushd yottadb_r*
		if ($verno =~ "*V7*") then
			# the --utf8 option does not accept an ICU version in GT.M V7.0-000 or later
			./ydbinstall --installdir=$gtm_root/$verno/$dbgpro --utf8 --keep-obj --ucaseonly-utils --prompt-for-group --overwrite-existing
		else
			./ydbinstall --installdir=$gtm_root/$verno/$dbgpro --utf8 default --keep-obj --ucaseonly-utils --prompt-for-group --overwrite-existing
		endif
	popd
endif
mkdir -p $gtm_root/$verno/$dbgpro/obj
find . -name '*.a' -exec cp {} $gtm_root/$verno/$dbgpro/obj \;
mkdir -p $gtm_root/$verno/tools

cd $source_dir
cp sr_unix/*.awk $gtm_root/$verno/tools
cp sr_unix/*.csh $gtm_root/$verno/tools
cp sr_linux/*.csh $gtm_root/$verno/tools
cp $gtm_root/$verno/$dbgpro/custom_errors_sample.txt $gtm_root/$verno/tools
rm -f $gtm_root/$verno/tools/setactive{,1}.csh

set machtype=`uname -m`
foreach ext (c s msg h si)
	if (($ext == "h") || ($ext == "si")) then
		set dir = "inc"
	else
		set dir = "src"
	endif
	mkdir -p $gtm_ver/$dir

	foreach sr_dir (sr_port sr_port_cm sr_unix sr_unix_cm sr_unix_gnp sr_x86_regs sr_${machtype} sr_linux)
		set filecount=`find "${sr_dir}/" -maxdepth 1 -name "*.$ext" | wc -l`
		if (${machtype} == "x86_64" && ${sr_dir} == "sr_x86_regs" && $filecount > 0) then
			cp -pa ${sr_dir}/*.$ext $gtm_ver/$dir/
		else if ($filecount > 0) then
			cp -pa ${sr_dir}/*.$ext $gtm_ver/$dir/
		endif
	end
end

# Copy xfer_desc.i (if it exists) to $gtm_inc
if (-e $source_dir/$dbgpro/xfer_desc.i) then
	cp -pa $source_dir/$dbgpro/xfer_desc.i $gtm_ver/inc
endif

# gtm_threadgbl_deftypes.h used to be in "gen" directory previously. Now it is in "genused" directory.
# Handle both cases in this script
foreach dir (gen genused)
	if (-e $source_dir/$dbgpro/$dir/gtm_threadgbl_deftypes.h) then
		cp -pa $source_dir/$dbgpro/$dir/gtm_threadgbl_deftypes.h $gtm_ver/inc
	endif
end

# Sudo tests require `ydbinstall` that is part of the intermediate build process (yuck)
# But the intermediate objects take up about 5GB
# So try to preserve `ydbinstall`, but delete the rest
# /Distrib/YottaDB/${gtm_verno}/${tst_image}/yottadb_r*/ydbinstall
if ( "$git_tag" == "master" ) then
	set ydbinstall = `find ${source_dir}/${dbgpro} -name 'ydbinstall' -not -path '*utf8*'`
	mv $source_dir/$dbgpro/yottadb_r*/ydbinstall /tmp/
	rm -rf $source_dir/$dbgpro
	mkdir -p $ydbinstall:h
	mv /tmp/ydbinstall $ydbinstall:h
else
	rm -rf $source_dir/$dbgpro
endif

# Install gtmcrypt plugin
setenv ydb_dist /usr/library/$verno/$dbgpro
setenv gtm_dist $ydb_dist
if ( $is_gtm ) then
	set tmpdir = "/tmp/__buildrel_${user}_$$"
	if (-e $tmpdir) then
		rm -rf $tmpdir
	endif
	mkdir $tmpdir
	pushd $tmpdir
	tar xf $ydb_dist/plugin/gtmcrypt/source.tar
	setenv LC_ALL en_US.utf8
	setenv gtm_icu_version `pkg-config --modversion icu-io`
	make install
	popd
	rm -rf $tmpdir
else
	setenv ydb_icu_version `pkg-config --modversion icu-io`
	cd /Distrib/YDBEncrypt
	make && make install && make clean
	find $ydb_dist/plugin -type f -exec chown root:root {} +
	cd -
	rm -rf /tmp/plugin-build
	# These should be done by the plugin but done by ydbinstall instead
	mv $ydb_dist/plugin/gtmcrypt $ydb_dist/plugin/ydbcrypt
	ln -s $ydb_dist/plugin/ydbcrypt $ydb_dist/plugin/gtmcrypt
endif

# Enable execute permissions on .sh scripts in the YDBEncrypt plugin
chmod +x ${ydb_dist}/plugin/gtmcrypt/*.sh

# Install GTMJI plugin
# The make step below needs JAVA_HOME and JAVA_SO_HOME env vars set appropriately so set that up first using "set_java_paths.csh"
# But before that set up "tst_awk" and "HOSTOS" env var so "set_java_paths.csh" can work without errors.
setenv HOSTOS `uname -s`
# gtm_test_serverconf_file and gtm_dist variables are needed for installing GTMJI Plugin
setenv gtm_test_serverconf_file /usr/library/gtm_test/T999/docker/serverconf.txt
setenv tst_awk gawk	# needed for "set_java_paths.csh"
source /usr/library/gtm_test/set_java_paths.csh
cd /Distrib/ji_plugin/ji_plugin_1.0.4
make install && make clean
cd -

# Install Posix Plugin
if ( $is_gtm ) then
	cd /Distrib/posix_plugin_r2
	make install
	make clean
else
	mkdir -p /tmp/plugin-build/posix-build && cd /tmp/plugin-build/posix-build
	cmake /Distrib/YDBPosix && make && make install
	cd -
	rm -rf /tmp/plugin-build
endif
