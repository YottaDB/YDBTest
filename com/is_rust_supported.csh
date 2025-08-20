#################################################################
#                                                               #
# Copyright (c) 2020-2025 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

if ("aarch64" == `uname -m`) then
	# On AARCH64,
	# 1) The cargo/rustc system-wide installation done by the package manager does not work on Debian.
	#    One needs to install it in each user's home directory. This takes up a lot of space in /home.
	# 2) Even if one installs it in /home for each user, once in a while I have seen SIG-11 at random
	#    points in the rust compiler when downloading/building dependent packages for imptp.rs.
	# Given the above, we just treat AARCH64 as a rust unsupported platform for testing purposes.
	echo false
else
	echo true
endif

