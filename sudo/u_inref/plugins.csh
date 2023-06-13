#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "# This tests that ydbinstall successfully installs plugins for a "
echo "# random set of plugs-in (--octo --gui --aim --encplugin --posix --zlib),"
echo "# and randomly picking --plugins-only and --utf8."

# Set the chset to UTF-8. We need to do this to ensure the locale is set correctly
# and avoid %YDB-E-NONUTF8LOCALE errors when testing --zlib --utf8
$switch_chset "UTF-8"

# Possible options being used in the test
set arr = ( "--octo" "--gui" "--aim" "--encplugin" "--posix" "--zlib" "--plugins-only" "--utf8" "--sodium" "--allplugins" )

# 8 runs
set run_count = 1
while ( $run_count <= 8 )
	@ run_count++

	# Pick random number of options to use
	set options_count = `shuf -i 1-$#arr -n 1`

	# Of these, pick random ones
	set random_options_numbers = `shuf -i 1-$#arr -n $options_count`

	# Create the final option list going into the test
	set option_list = ""
	# Need to get `plugins_only` separately as a flag as it's passed to the
	# bash script ./plugins.sh, which uses it to install the original
	# yottadb install and then install plugins over it.
	set plugins_only = "no"
	foreach option_number ($random_options_numbers)
		set option_name = "$arr[$option_number]"
		if ( "$option_name" == "--plugins-only" ) then
			set plugins_only = "yes"
		else
			set option_list = "$option_list$option_name "
		endif
	end

	# setup of the image environment
	mkdir install # the install destination
	cd install

	# we have to make this folder before hand otherwise the installer will throw out errors
	# this happens only when this script is invoked by the test system
	# it works fine without permission issues when run as root in an interactive terminal
	mkdir gtmsecshrdir
	chmod -R 755 .

	cp $gtm_tst/$tst/u_inref/plugins.sh  .

	# we pass these things as variables to plugins.sh because it doesn't inherit the tcsh
	# environment variables. The below sets the variable "installoptions"
	# (e.g. "--force-install" if needed)
	source $gtm_tst/$tst/u_inref/setinstalloptions.csh
	$echoline >> ../plugins_install.log
	echo "Testing $option_list" >> ../plugins_install.log
	$sudostr sh ./plugins.sh $gtm_verno $tst_image `pwd` "$installoptions" "$option_list" $plugins_only >> ../plugins_install.log
	# clean up the install directory since the files are owned by root
	cd ..
	sudo rm -rf install
end

set ntests_succeeded = `grep -c 'ydbinstall with options .* was successful' plugins_install.log`
echo "# Test that $ntests_succeeded of 8 tests succeeded"
grep "non-zero status" plugins_install.log
if !($status) then
	echo "# Test failed. Check plugins_install.log"
else
	echo "# Test succeeded."
endif
