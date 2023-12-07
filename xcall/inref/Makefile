##########################################################
#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.
# All rights reserved.
#
#	This source code contains the intellectual property
#	of its copyright holder(s), and is made available
#	under a license.  If you do not know the terms of
#	the license, please stop and do not read further.
#
##########################################################

# Developer tool for faster quick-n-dirty test-running of .so and .m files without all the test framework as follows:
#   make retvals     # to test just retvals.m and retvals.so
#   make run         # to test all $(TARGETS)

ydb_dist ?= $(firstword $(wildcard /usr/library/V999_R*/pro))
ydb_dist ?= /usr/local/lib/yottadb/r139

CC := gcc
CFLAGS := -fPIC -shared -I$(ydb_dist) -I../../com/ -L$(ydb_dist) -lyottadb -Wl,-rpath,$(ydb_dist)
TARGETS := retvals ydbtypes

all: run

%.so: %.c
	$(CC) $< -o $@  $(CFLAGS)

# This rule is included to quickly test-run a .m file with environment variables set per below
*.m:
	$(ydb_dist)/yottadb -run $(basename $@)
.PHONY: *.m

$(TARGETS): %: %.so
	echo
	echo "Running M & C parts of $@ test"
	$(ydb_dist)/yottadb -run $@
.PHONY: $(TARGETS)

run: $(TARGETS)

clean:
	rm -f *.so *.o

export LD_LIBRARY_PATH := $(ydb_dist):$(LD_LIBRARY_PATH)
export ydb_routines := . $(ydb_dist)/libyottadbutil.so $(ydb_dist)/libyottadb.so

# If you want to test with UTF-8:
export LANG := en_US.UTF-8
export ydb_chset := UTF-8
export ydb_icu_version := $(shell pkg-config --modversion icu-io)

# Export all ydb_xc_* variables for all targets
$(foreach target,$(TARGETS),$(eval export ydb_xc_$(target):=$(target).xc))
