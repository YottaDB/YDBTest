#################################################################
#								#
# Copyright (c) 2019-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Never invoked as a base script. Always sourced from a caller tcsh script (e.g. sourceInstall.csh, diffDir.csh etc.).
set linux_distrib = `awk -F= '$1 == "ID" {print $2}' /etc/os-release | sed 's/"//g'`
set osver = `awk -F= '$1 == "VERSION_ID" {print $2}' /etc/os-release | sed 's/"//g'`
set installoptions = ""
if (("$linux_distrib" == "arch")							\
		|| (("$linux_distrib" == "debian") && (`uname -m` == "aarch64"))	\
		|| (("$linux_distrib" == "raspbian") && (`uname -m` == "armv6l"))) then
	set installoptions = "$installoptions --force-install"
endif
