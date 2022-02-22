#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
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

foreach zlib ("no" "yes")
	foreach posix ("no" "yes")
		foreach enc ("no" "yes")
			foreach aim ("no" "yes")
				if ("no" == $aim && "no" == $enc && "no" == "$posix" && "no" == "$zlib") then
					continue
				endif
				setenv plugins ""
				if ("yes" == $aim) then
					setenv plugins "--aim"
				endif
				if ("yes" == $enc) then
					if ("yes" == $aim) then
						setenv plugins "$plugins --encplugin"
					else
						setenv plugins "--encplugin"
					endif
				endif
				if ("yes" == $posix) then
					if ("yes" == $aim || "yes" == $enc) then
						setenv plugins "$plugins --posix"
					else
						setenv plugins "--posix"
					endif
				endif
				if ("yes" == $zlib) then
					if ("yes" == $aim || "yes" == $enc || "yes" == $posix) then
						setenv plugins "$plugins --zlib"
					else
						setenv plugins "--zlib"
					endif
				endif
				foreach pluginsonly ("no" "yes")
					foreach utf ("no" "yes")
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
					# environment variablesThe below sets the variable "installoptions"
					# (e.g. "--force-install" if needed)
					source $gtm_tst/$tst/u_inref/setinstalloptions.csh
					$echoline
					if ("no" == $utf) then
						if ("no" == $pluginsonly) then
							echo "testing with options $plugins"
						else
							echo "testing with options --plugins-only $plugins"
						endif
						$sudostr sh ./plugins.sh $gtm_verno $tst_image `pwd` "$installoptions" "$plugins" "$pluginsonly"
					else
						if ("no" == $pluginsonly) then
							echo "testing with options $plugins --utf8 default"
						else
							echo "testing with options --plugins-only $plugins --utf8 default"
						endif
						set installoptions = "$installoptions --utf8 default"
						$sudostr sh ./plugins.sh $gtm_verno $tst_image `pwd` "$installoptions" "$plugins" "$pluginsonly"
					endif
					# clean up the install directory since the files are owned by root
					cd ..
					sudo rm -rf install
					end
				end
			end
		end
	end
end
