#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# The following command illustrates how to use makebuild.csh to execute the
# Makefile build outside of the test system
# /gtc/staff/gtm_test/current/T990/manually_start/u_inref/makebuild.csh V9.9-0 |& tee -a ~/logs/mk_`hostname`_`date +%Y%m%d`.log

# need $PWD, make sure it exists
if ( !($?PWD) ) then
	setenv PWD "`pwd`"
endif

set ver=${1}
set verdir=${ver:s/.//:s/-//}
# Build directory if we're not in the test system
if ( !($?gtm_tst) ) then
	set stamp = `date +%Y%m%d%H%M`
	mkdir -p /testarea1/${USER}/${verdir}/makebuild_${stamp}
	pushd /testarea1/${USER}/${verdir}/makebuild_${stamp}
endif

if ( ! -X cmake ) then
	echo "There is no cmake. exiting!"
	exit 1
endif

set withcurpro = ""
if ($?gtm_tst) then
	set withcurpro = `$gtm_dist/mumps -run chooseamong "" "-DGTM_DIST:PATH=/usr/library/${gtm_curpro}/pro" `
endif
cmake --version >& usecmake
# This is somewhat convoluted
#  IF major != 2, then EXIT with the result of (major < 2 ) - TRUE is a non-zero status to the shell
#  After this point, we know that we are dealing with version 2 cmake so we test the minor and sub version
#  EXIT with the result of (minor<8 || (minor==8 && subv<5)) - TRUE is a non-zero status to the shell
awk '{split($3,V,".");major=0+V[1];minor=0+V[2];subv=0+V[3];if(major!=2){exit(major<2)};exit(minor<8 || (minor==8 && subv<5));}' usecmake  #BYPASSOK awk
if ( $status ) then
	echo "cmake version is less than 2.8"
	mv usecmake dontusecmake
	exit 101
endif

# to override where the source tarball comes from use '-env srcuser=$USER'
if !($?srcuser) then
	set srcuser = "library"
endif

# need to match tools/cms_tools/server_list
set osarch = ${HOSTOS:al:as/-//:as/sunos/solaris/}_${MACHTYPE:al:as/_//:as/-//:as/i386/i686/:s/unknown/ia64/}
set witharch = gtm_${verdir}_${osarch}_src.tar.gz
# new arch independent tarball name
set noarch = fis-gtm-${ver}.tar.gz
# Copy target sources. The source tarball includes the OS and ARCH in the file name
# NOTE: use the override to test with your User ID

set tarball = /gtc/staff/${srcuser}/kitftp/${verdir}/opensource/${noarch}
set needsMassage=0
echo "Checking for ${tarball}"
if ( ! -e ${tarball} ) then
	set tarball = /gtc/staff/${srcuser}/kitftp/${verdir}/opensource/${witharch}
	echo "Checking for ${tarball}"
endif
if ( -e ${tarball} ) then
	echo "Using ${tarball}"
	cp ${tarball} .
	gunzip ${tarball:t}
	tar xf ${tarball:t:r}
	# need to move up all files from fis-gtm-${ver} to $PWD so the rest of the script works
	if (-d fis-gtm-${ver} ) mv fis-gtm-${ver}/* ./
else
	set needsMassage=1
	# When using doall/rununix, add "-env work_dir=$work_dir" to the command line to build with
	# sources from your git repo
	if ($?work_dir) then
		echo "Using ${work_dir}/gtm"
		cp -r ${work_dir}/gtm/* .
	else if ($?gitbranch && $?giturl) then
		echo "Using ${giturl} branch ${gitbranch}"
		git init
		git remote add remotehost $giturl
		git fetch remotehost
		git checkout $gitbranch
	else if ( -d ${cms_root}/${verdir} ) then
		echo "Using ${cms_root}/${verdir}"
		cp -r ${cms_root}/${verdir}/* .
	else
		echo 'TEST-I-INFO: Either set up a symlink to V990'
		echo 'TEST-I-INFO:   ln -s $cms_root/V990 $cms_root/'${verdir}
		echo "TEST-I-INFO: OR execute this test with one of the following"
		echo 'TEST-I-INFO:   -env work_dir=$work_dir'
		echo 'TEST-I-INFO:   -env giturl="ssh://twinata/${work_dir}/gtm" -env gitbranch=branch'
		echo "TEST-I-INFO:     Replace twinata and branch as necessary"
		echo "Using ${cms_root}/V990"
		cp -r ${cms_root}/V990/* .
	endif

	# copy the stuff from $cms_tools/
	foreach file ( $cms_tools/opensource_* )
		cp $file ./${file:t:s/opensource_//}
	end

	if ($?gtm_src && $?gtm_inc ) then
		# Cannot build these with just GT.M sources
		cp $gtm_pct/GTMDefinedTypesInitPro.m sr_${MACHTYPE:al:as/-//:as/i686/i386/}/GTMDefinedTypesInitRelease.m
		cp $gtm_pct/GTMDefinedTypesInitDbg.m sr_${MACHTYPE:al:as/-//:as/i686/i386/}/GTMDefinedTypesInitDebug.m
		if ( "" == "${withcurpro}" ) then
			# copy $gtm_src/ttt.c $gtm_src/*_ctl.c $gtm_inc/merrors_ansi.h to sr_<arch>
			cp $gtm_src/ttt.c $gtm_src/*_ctl.c $gtm_inc/merrors_ansi.h sr_${MACHTYPE:al:as/-//:as/i686/i386/}

		endif
	else
		echo "Cannot copy \$gtm_src/ttt.c \$gtm_src/*_ctl.c \$gtm_inc/merrors_ansi.h to sr_<arch> for cmake"
	endif
endif

if ( ! -e ./sr_port) then
	# If sr_port does not exist, then we don't have the sources, exit
	ls -ltr
	exit 1
endif

if ( $?gtm_icu_version ) then
	set icuver=$gtm_icu_version
else
	which pkg-config && set icuver=`pkg-config --modversion icu-io`
endif

# Prefer GNU make if it is not the default make
if ( ! -X gmake ) alias gmake make

if ( $needsMassage ) then
	# Massage files now in case that external files were copied in
	#
	# 12.04 due to a bad interaction between the deprecated -I- option and
	# GCC. See mails with the subject:
	# 	[GTM-6465] [cmake] #include "" vs #include <>
	# Keep in sync with tools/cms_tools/kitsource.csh
	echo "Massage the source files so that we can build on i386 Linux and other platforms without -I-"
	set hdrlist="emit_code_sp.h|rtnhdr.h|auto_zlink.h|make_mode_sp.h|auto_zlink_sp.h|emit_code.h|mdefsp.h|incr_link_sp.h|gtm_mtio.h|obj_filesp.h|zbreaksp.h|gtm_registers.h|opcode_def.h" #BYPASSOK line length
	set sedlist=${hdrlist:as/|/ /:as/ /\|/} # fixing for use with SED requires some contortions - replace | with space and then space with \|
	find sr_* -type f -exec grep -lE "#include .(${hdrlist})." {} + > changefiles.list #BYPASSOK grep
	foreach file (`cat changefiles.list`)
		set orig=${file:h}/.${file:t}
		mv ${file} {$orig}
		sed "s/#include .\(${sedlist}\)./#include <\1>/g" ${orig} > ${file}
		diff -u ${orig} ${file}
		rm ${orig}
	end
endif
unset echo

# ENV : PATH - strip "." and all gtc references from the current PATH
$gtm_exe/mumps -run %XCMD 'set PATH=$ztrnlnm("PATH"),plen=$length(PATH,":") for i=1:1:plen set cdir=$piece(PATH,":",i) set:cdir\'="."&\'(cdir["gtc") $piece(newpath,":",$i(newi))=cdir write:i=plen "setenv PATH """,newpath,"""",\!' >&! PATH.csh
if (-e PATH.csh && ("V54002" != ${ver})) source PATH.csh

# ENV : Reset - need to retain $gtm_com and $gtm_tst for switch_chset
env | awk -F"=" '$1 !~ /^(gtm_com|gtm_tst)/ && $1 ~ /^(LC_|gt|sr_|cms|cvs|CVS|s_|com_|work_|test_|assembler_|books_|articles_)/{print "unsetenv "$1}' >>& sourceme.csh  #BYPASSOK awk
source sourceme.csh

# setup for a clean UTF-8 environment so that we don't get spurious NONUTF8LOCALE messages
# depending on the list of locales configured, locale -a might be considered a binary output. (on scylla currently)
# grep needs -a option to process the output as text to get the actual value instead of "Binary file (standard input) matches"
# but -a is not supported on the non-linux servers we have.
if ("Linux" == "$HOSTOS") then
	set binaryopt = "-a"
else
	set binaryopt = ""
endif
set utflocale = `locale -a | grep $binaryopt -iE 'en_us\.utf.?8$' | head -n 1`  # BYPASSOK grep head
# MAYBE
# set libpath = `icu-config --ldflags-searchpath`	# If ever this line is uncommented, we need to
							# find the equivalent pkg-config command for this.
set libpath="/usr/local/lib64:/usr/local/lib:/usr/local/ssl/lib"
set lpwd = $PWD
if ( "" == "${withcurpro}" ) then
	echo "Build with pregenerated files (built on the distribution servers)"
else
	echo "Build with the current production GT.M generating ttt.c, _ctl.c and merrors_anshi.h"
endif
# Tell CMake to search /usr/local/lib64:/usr/local/lib ahead of the usual system directories
# this was done for Solaris 10 and it doesn't seem to hurt Linux
setenv CMAKE_PREFIX_PATH /usr/local/lib64:/usr/local/lib:/usr/local/ssl/lib
foreach bld (Release Debug)
	set echo
	mkdir ${bld}
	cd ${bld}
	# invoke CMake and build!
	cmake -D GTM_RELEASE_VERSION="${ver}" -D CMAKE_BUILD_TYPE:STRING=${bld} -D CMAKE_INSTALL_PREFIX:PATH=${lpwd}/install_${bld} ${withcurpro} .. || exit $status
	make -j 4 >&! ../${bld}_build.log
	# if mumps was not built, just exit
	if ( ! -e mumps ) then
		echo "mumps not built"
		exit 11
	endif
	make install
	set GTM_INSTALL_DIR=`awk -F'=' '/GTM_INSTALL_DIR/{print $2}' CMakeCache.txt`  #BYPASSOK awk
	cd ..
	set ldist="$PWD/install_${bld}/${GTM_INSTALL_DIR}"
	env gtm_dist=${ldist} gtmroutines=${ldist} ${ldist}/mumps -run %XCMD 'write "PASS",!'

	# Now test the gtmcrypt Makefile
	pushd $ldist/plugin/gtmcrypt
	env gtm_dist=${ldist} make uninstall	|| echo "TEST-F-FAIL Uninstalling the plugin did not work"
	env gtm_dist=${ldist} make		|| echo "TEST-F-FAIL Compiling the plugin did not work"
	env gtm_dist=${ldist} make install	|| echo "TEST-F-FAIL Installing the plugin did not work"
	popd

	# Create symlinks that the parent script uses to drive the build test
	if ( "Release" == "${bld}" ) then
		ln -s ${ldist} pro
	else
		ln -s ${ldist} dbg
	endif
	unset echo
end

