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
echo "# This tests that ydbinstall successfully installs plugins using the --plugins-only"
echo "# option for each possible combination of plugins with and without UTF-8 support."

# Set the chset to UTF-8. We need to do this to ensure the locale is set correctly
# and avoid %YDB-E-NONUTF8LOCALE errors when testing --zlib --utf8 default
$switch_chset "UTF-8"

setenv aim "--aim"
setenv enc "--encplugin"
setenv posix "--posix"
setenv zlib "--zlib"
foreach plugins ("$aim" "$enc" "$posix" "$zlib" "$aim $enc" "$aim $posix" "$aim $zlib" "$enc $posix" "$enc $zlib" "$posix $zlib" "$aim $enc $posix" "$aim $enc $zlib" "$aim $posix $zlib" "$enc $posix $zlib" "$aim $enc $posix $zlib")
	foreach utf ("no" "yes")
		# setup of the image environment
		mkdir install # the install destination
		cd install
		# we have to make this folder before hand otherwise the installer will throw out errors
		# this happens only when this script is invoked by the test system
		# it works fine without permission issues when run as root in an interactive terminal
		mkdir gtmsecshrdir
		chmod -R 755 .

		cp $gtm_tst/$tst/u_inref/pluginsonly.sh  .

		# we pass these things as variables to plugins.sh because it doesn't inherit the tcsh environment variables
		source $gtm_tst/$tst/u_inref/setinstalloptions.csh # sets the variable "installoptions" (e.g. "--force-install" if needed)
		$echoline
		if ("no" == $utf) then
			echo "testing with options $plugins"
			sudo sh ./pluginsonly.sh $gtm_verno $tst_image `pwd` "$installoptions" "$plugins"
		else
			echo "testing with options $plugins --utf8 default"
			set installoptions = "$installoptions --utf8 default"
			sudo sh ./pluginsonly.sh $gtm_verno $tst_image `pwd` "$installoptions" "$plugins"
		endif
		# clean up the install directory since the files are owned by root
		cd ..
		sudo rm -rf install
	end
end

