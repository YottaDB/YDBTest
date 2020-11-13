#################################################################
#                                                               #
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################

set release = `grep ^NAME= /etc/os-release | cut -d = -f 2 | tr -d '"'`
set version = `grep VERSION_ID= /etc/os-release | cut -d = -f 2 | tr -d '"'`

if ("armv6l" == `uname -m`) then
	# Rust is currently disabled on ARMV6L due to a compiler bug that sometimes causes
	# it to SIG-11 while building imptp on ARMV6L machines. Once the bug is fixed in
	# the Rust compiler, Rust should be re-enabled on ARMV6L machines.
	# https://github.com/rust-lang/rust/issues/72894
	echo false
else if ("$release" =~ Raspbian*) then
        # These have an ancient version of rustc, 1.24
        if ("$version" == 9) then
                echo false
        else
                echo true
        endif
else if ("$release" =~ 'Red Hat Enterprise Linux*') then
        # These have an old version of clang (3.4), and do not have libclang at all
        if ("$version" =~ 7*) then
                echo false
        else
                echo true
        endif
else
        echo true
endif

## Platforms where YDBRust is known to work:
#    PRETTY_NAME="Ubuntu 18.04.4 LTS"
#    PRETTY_NAME="CentOS Linux 8 (Core)"
#    PRETTY_NAME="Debian GNU/Linux 9 (stretch)"

# Platforms where YDBRust will work if the current bugs are fixed
# https://gitlab.com/YottaDB/Lang/YDBRust/-/merge_requests/78
#    PRETTY_NAME="Raspbian GNU/Linux 10 (buster)"

# Platforms where YDBRust is known to not work:
#    PRETTY_NAME="Raspbian GNU/Linux 9 (stretch)"

## These have an old version of clang (3.4), and do not have libclang at all
#    PRETTY_NAME="Red Hat Enterprise Linux"
#    VERSION_ID="7.8"

# Platforms where YDBRust may work:
#    PRETTY_NAME="Arch Linux"
#    PRETTY_NAME="Ubuntu 19.10"
#    PRETTY_NAME="Debian GNU/Linux 10 (buster)"
