#!/usr/local/bin/tcsh
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
echo "# This tests that ydbinstall successfully installs plugins for each"
echo "# possible combination of plugins with and without UTF-8 support."

# Set the chset to UTF-8. We need to do this to ensure the locale is set correctly
# and avoid %YDB-E-NONUTF8LOCALE errors when testing --zlib --utf8 default
$switch_chset "UTF-8"

setenv aim "--aim"
setenv enc "--encplugin"
setenv posix "--posix"
setenv zlib "--zlib"
setenv utf "--utf8 default"
foreach plugins ("$aim" "$enc" "$posix" "$zlib" "$aim $utf" "$enc $utf" "$posix $utf" "$zlib $utf" "$aim $enc" "$aim $posix" "$aim $zlib" "$aim $enc $utf" "$aim $posix $utf" "$aim $zlib $utf" "$enc $posix" "$enc $zlib" "$enc $posix $utf" "$enc $zlib $utf" "$posix $zlib" "$posix $zlib $utf" "$aim $enc $posix" "$aim $enc $zlib" "$aim $posix $zlib" "$enc $posix $zlib" "$aim $enc $posix $utf" "$aim $enc $zlib $utf" "$aim $posix $zlib $utf" "$enc $posix $zlib $utf" "$aim $enc $posix $zlib" "$aim $enc $posix $zlib $utf")
	# setup of the image environment
	mkdir install # the install destination
	cd install
	# we have to make this folder before hand otherwise the installer will throw out errors
	# this happens only when this script is invoked by the test system
	# it works fine without permission issues when run as root in an interactive terminal
	mkdir gtmsecshrdir
	chmod -R 755 .

	cp $gtm_tst/$tst/u_inref/plugins.sh  .

	# we pass these things as variables to plugins.sh because it doesn't inherit the tcsh environment variables
	source $gtm_tst/$tst/u_inref/setinstalloptions.csh # sets the variable "installoptions" (e.g. "--force-install" if needed)
	$echoline
	echo "testing with options $plugins"
	sudo sh ./plugins.sh $gtm_verno $tst_image `pwd` "$installoptions" "$plugins"

	# clean up the install directory since the files are owned by root
	cd ..
	sudo rm -rf install
end

