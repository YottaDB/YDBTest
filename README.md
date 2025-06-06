# YottaDB Test System

All software in this package is part of YottaDB (<https://yottadb.com>) each file of which identifies its copyright holders. The software is made available to you under the terms of a license. Refer to the [License section](#License) and [LICENSE file](LICENSE) for details.

# Overview

This test system is the regression test suite for YottaDB. It is a collection of shell scripts written for the tcsh shell on Linux. It is a complex system that enables simultaneous testing across servers (but may also be used locally), and offers a randomized selection of a variety of settings that cannot be tested exhaustively in every permutation every time.

The documentation for the test system is what follows, and help for the primary test command may be obtained with the command `gtmtest -help` (`gtmtest` is named after the upstream software, GT.M, of which YottaDB is a superset fork).

The test system assumes a particular directory structure and a large number of environment variables, which specify that directory structure and various other parameters.

Because the set-up process is fairly involved, the repository supplies a Dockerfile, which is probably the easiest way to run the test system. Instructions are available in the [dockerfile section](#using-the-test-system-with-docker) below.

## License

If you receive this package integrated with a YottaDB distribution, the license for your YottaDB regression test suite is that of YottaDB under the terms of its license.

Simple aggregation or bundling of this package with another for distribution does not create a derivative work. To make clear the distinction between this package and another with which it is aggregated or bundled, it suffices to place the package in a separate directory or folder when distributing the aggregate or bundle.

Should you receive this package not integrated with a YottaDB distribution, and missing a COPYING file, you may create a file called COPYING from the GNU Affero General Public License Version 3 or later (<https://www.gnu.org/licenses/agpl.txt>) and use this package under the terms of that license.

# Setup

## Pre-commit hooks

You should install pre-commit hooks before committing to this repository. To install the pre-commit hooks, run the following from the directory of the cloned repository:

```sh
ln -s ../../pre-commit .git/hooks
```

## Prerequisites

To run tests without using the [Dockerfile](#using-the-test-system-with-docker), required binaries include:

- tcsh, ksh, gawk, sed, lsof, bc, strace, expect, gdb, ssh
- sort, fuser, eu-elflint, ss, nc

If you are using a Debian or Ubuntu based distribution, the following command will install all required packages to build and test YottaDB:

```sh
sudo apt-get install -y --no-install-recommends \
    tcsh ksh gawk sed lsof bc strace expect gdb ssh \
    coreutils psmisc elfutils iproute2 netcat-traditional \
    file cmake make gcc pkg-config git libconfig-dev \
    libelf-dev libgcrypt-dev libgpg-error-dev libgpgme11-dev libicu-dev libncurses-dev libssl-dev \
    libreadline-dev zlib1g-dev unzip wget ca-certificates psmisc vim rsyslog \
    locales net-tools valgrind \
    python3 python3-venv python3-dev python3-setuptools \
    golang curl default-jdk libffi-dev \
```

Make sure syslog is running and readable:

```sh
ps aux | grep -q "[r]syslogd" || sudo rsyslogd # runs syslogd if not already running
sudo chmod g+r /var/log/syslog                 # enable read permissions on syslog
sudo adduser `whoami` adm; newgrp -   # necessary on Debian for user to read syslog
```

Only if you're setting up a **minimal docker image**, you'll also need to remove kernel logging to prevent warnings when starting `rsyslogd` with:
    `sudo sed -i -Ee 's/^(module.*imklog.*)/#\1/' /etc/rsyslog.conf`

Currently **tcsh** is the only supported shell. Make sure that tcsh is properly installed and that you can run it with the following command:

```sh
tcsh
```

A symbolic link to tcsh is also needed in local bin:

```sh
sudo ln -s /usr/bin/tcsh /usr/local/bin/tcsh
```

Setup **password-less SSH** to yourself (required for some tests):

```sh
apt install ssh
[ -e /.dockerenv ] && /etc/init.d/ssh start   # Only needed/runs on docker images
cd ~/.ssh
[ ! -e id_rsa.pub ] && ssh-keygen -f id_rsa -N ''
cat id_rsa.pub >>authorized_keys
chmod 600 authorized_keys
cd ..
```

Now check that you can run ``ssh `hostname` `` without having to enter a password.

Make sure coredumps appear in your current directory, which is required by a number of tests. Read the current setting with ``sysctl kernel.core_pattern`. If it does not say `core*` then do the following:

```sh
echo kernel.core_pattern=core | sudo tee -a /etc/sysctl.conf
sysctl -p   # apply the change to the currently running kernel
```

### Optional setup for *perf*ormance tests

Some tests (e.g. v70005/strcat_efficiency) use `perf` to measure performance features (CPU instructions) for certain database functions. These tests are skipped if `perf` is not installed, but `perf` requires specific setup if installed:

Install `perf` as follows to match your OS:

```sh
apt install linux-tools-common  # Ubuntu
apt install linux-tools-<kernel-version>-generic  # Ubuntu if you updated the kernel
apt install linux-perf          # Debian
yum install perf                # RHEL
```

If `perf` returns an access error including a message `perf_event_paranoid setting is 4` then you need to set it to 2 as follows:

```sh
# set permissions for now until reboot
echo 2 | sudo tee /proc/sys/kernel/perf_event_paranoid

# For permanence, this adds or /etc/sysctl.conf or edits the line if the setting already exists
# (explanation at https://stackoverflow.com/a/49852337/1232094)
sudo sed -Ei \
    -e '/^\s*#?\s*(kernel.perf_event_paranoid\s*=\s*).*/{s//\12 # enable perf/;:a;n;ba;q}' \
    -e '$akernel.perf_event_paranoid=2 # enable perf' /etc/sysctl.conf
```

## Environment variables

Merge this [.cshrc template](com/.cshrc) into your own `.cshrc` in your home directory. Edit it, and find the section headed "User-specific locations" and **edit the variable values** to match your own contact details and available directories on your machine.

Note: If you now try to run tcsh, without having first fetched [YDBTest (below)](#getting-the-ydbtest-repository), it will produced a "no such file" error since the `.cshrc` file tries to source `YDBTest/com/set_env.csh` to set up additional environment variables for `gtmtest`.

Various **handy testing aliases** are defined by `YDBTest/com/set_env.csh`. If you wish to override any of these on your local system, redefined them in your `.cshrc` after it sources `YDBTest/com/set_env.csh`. Notably, `.cshrc` includes the following aliases (type `alias <name>` to remind yourself what of they do):

```sh
gitlog    # pretty-print the git log in one line format (or you might prefer to install the more powerful `tig`)
gitup     # update your git directory from upstream/master using rebase
gitsquash # squash all commits since origin/master and prepare them, ready for commit.
precmd    # shows the git branch in your prompt
```

The following of these environment variables, defined in `.cshrc` will be referenced in the documentation below:

```sh
setenv build_id 996                # Your build number: any 9xx no.; assigned by YottaDB on their servers: avoids clobbering others' builds
setenv verno V${build_id}_R139     # Change Rxxx to match the revision of yottadb you will install and test aginst
setenv work_dir ~/work             # Where you wish to check out YDB, YDBTest, etc.
setenv gtm_root /usr/library       # Where your (and others') installed binaries go
setenv gtm_test $gtm_root/gtm_test # Where to hold a temporary copy of the tester code to run; it needn't be under $gtm_root
setenv tst_dir /testarea1/`whoami` # Where to put the output of your test
setenv r ~/.gtmresults             # Where to create symlink that points to latest test results directory; short name for easy access
```

You should change the above locations in your `.cshrc` to reference directories on your machine that your user has access to.
However, ***IF*** you wish to use the `.cshrc` template's default locations (using a directory structure used internally by YottaDB developers) you will need to create the above directories as follows:

```sh
sudo groupadd gtc
sudo adduser `whoami` gtc
sudo mkdir -p /testarea1/`whoami` /usr/library/gtm_test
sudo chown -R `whoami`:gtc /testarea1/ /testarea1/`whoami` /usr/library/gtm_test
```

## Getting the YDBTest repository

Get a clone of the YDBTest repository:

```sh
cd $work_dir
git clone https://gitlab.com/YottaDB/DB/YDBTest.git
```

`gtmtest` runs from a copy of the test source that must be at `$gtm_test`. Make this copy as follows:

```sh
mkdir -p $gtm_root/gtm_test/T${build_id}
tsync
```

`tsync` is an alias (defined by `.cshrc` via `test_env.csh`), that creates a copy of your test source directory. Your test source directory is taken to be the git repository of your current directory. Strictly, you need to run `tsync` before running a test, every time you change the source code; but the test-running aliases (e.g. `gtmtest`) that are defined in `test_env.csh` will do this for you. Here is a simplified version of `tsync`:

```sh
alias tsync 'rsync -av --delete `git rev-parse --show-toplevel`/ $gtm_test/$gtm_testver/'
```

## Building YottaDB
You need to install YottaDB in a specific way (the get-started page instructions won't work). This way is: `./ydbinstall --installdir=$gtm_root/$verno/$dbgpro --utf8 --keep-obj --ucaseonly-utils --prompt-for-group`.

- You need to install the current production version (append `setenv gtm_curpro <prod version>` after install to your `.cshrc`).
- You need to install the master version (and keep that periodically updated as master is updated)

Make sure your `.cshrc` sets `$gtm_curpro` to `<version>`. For example, append `setenv gtm_curpro V70001_R200` to your local `.cshrc` if your current production release is installed in `$gtm_root/V70001_R200/pro`.

At YottaDB, each version that we compile is a "pro" (Release) and "dbg" (Debug) version. They are stored in these directories:

```
$gtm_root/$verno/pro   # Where to store a production build
$gtm_root/$verno/dbg   # Where to store a debug build
```

If you work for YottaDB, use the [YDBDevOps repository](https://gitlab.com/YottaDB/Util/YDBDevOps) to build YottaDB. If you don't, you can use the file [docker/build_and_install_yottadb.csh](docker/build_and_install_yottadb.csh) to build YottaDB and copy all the correct files over. This file is used in pipelines to build YottaDB and run tests on it; so it should mostly work, but you may need to see how to use it by examining the accompanying [Dockerfile](docker/Dockerfile).

# Running a test

There are two methods to run a test: [monolithic testing](#monolithic-testing-with-gtmtest), using the `gtmtest` alias, and [modular testing](#modular-testing), described below. Monolithic testing is the canonical method used by YottaDB continuous integration. The modular testing method is for debugging tests and enables the developer to run tests directly, without going through the script layers of `gtmtest`.

Either testing method may be used on any platform (YottaDB servers, or on your localhost). Use in the docker image is not yet possible (it would require `.cshrc` template to be merged into the docker's `cshrc`).

For errors, see [troubleshooting](#troubleshooting) below.

## Monolithic testing with gtmtest

To run a test make sure that the shell is `tcsh`, then run `gtmtest`. See `gtmtest -h` for detailed option help, but the following arguments are common:

1. `-s`: Calls a specific test version's `gtmtest.csh`.
2. `-t`: Make the test system run all subtests of the given test name. If no test name is matched, run a subtest matching the given substring. Tab completion is available.
3. `-st`: An optional argument that will select comma-separated subtests of a test specified with `-t`.
4. `-replic`: An optional argument that runs the test with replication turned on.

An example of how to run the test system:

```sh
gtmtest -s r200 -t basic
gtmtest -s r200 -t basic -replic
```

Where `r200` names a particular version of YDBTest source code that you have copied into `$gtm_test/r200`.

### Other useful arguments

1. `-keep`: If a test passes, files related to the test will not be deleted
2. `-nozip`: Leaves files unzipped in the output directory
3. `-num_runs`: Using this qualifier followed by an integer will run the test for a specified number of times
4. `-h`: Prints out all valid arguments and a description of what they do
5. `-E_ALL`: Runs all tests (may take a long time to run all tests). When running an E_ALL, the `-t` argument is optional
6. `-env gtm_test_nomultihost=1`: Disables all multi-system tests. Highly recommended if you run an E_ALL without support for multi-system tests.
7. `-stdout`: Prints the output directly to stdout.
    1. `-stdout 0`: doesn't print any extra information
    2. `-stdout 1`: prints each subtest result
    3. `-stdout 2`: prints diff file for each failed subtest
    4. `-stdout 3`: prints verbose output; default

The results of the latest test may be found in various sub-directories of `$r` to let you create aliases such as the `difftest` example below.

### Cleanup

Since `gtmtest` stores a new set of test results every time you run it, you may wish to clean up historical test results. The **`cleantest`** alias will remove test results older than one day but keep at least the most recent test. You can run this into your `.cshrc` if you like.

## Modular Testing

Using the monolithic `gtmtest` has the difficulty that test bugs are difficult to find and diagnose because there are many script layers between running `gtmtest` and the sub-test itself being run. Eight layers, in fact:

* `gtmtest.csh` => `submit.csh` => `submit.awk` => `$submit_tests` (built by submit.awk)
   => `submit_test.csh` => \<testname\>`.csh` => `submit_subtest.csh` => \<subtest\>`.csh`

This means the developer cannot get easily "divide and conquer" to locate the offending code.

The solution is to use `settest` which sets up all the environment variables just like the above script layers, ready for the developer to directly invoke any specific test script.

* `settest` alias takes the same arguments as `gtmtest`, e.g. `-t <test> and -st <subtest>`

This sets the environment so the developer can jump in at any of the layers mentioned above, as follows:

* \<subtest\>`.csh` scripts can be run directly, though it leaves its artifacts in the current directory
* `runscript <script.csh>` alias invokes any specified test script directly, except collect its artifacts into `$r`
* `runtest` alias invokes `submit_test.csh` to run the test selected by `settest`, leaving artifacts in `$r`
* `runsubtest` similar to `runtest` but skips `submit_test.csh` and goes straight to `submit_subtest.csh` (fewer tester layers). Cannot run an entire test suite: only the subtest selected by `settest -st`.
* `YDBTest/com/*.csh` scripts can also be run directly (or with `runscript` to collate artifacts)
* `gtmtest` run a set of tests (see gtmtest -h), e.g. `gtmtest -t <test> and -st <subtest>`

To run a test script at any one of the above configurations, simply invoke the `settest` alias. It takes the same arguments specified by `gtmtest -help`, e.g. `-t <test>`, `-st <subtest>`.

### Examples

```sh
settest -help                        # show arguments help
settest -t xcall -st ydbtypes        # select test xcall/ydbtypes
settest -t ydbty                     # do the same as above using substring search
runtest                              # run xcall/ydbtypes selected above via submit_test.csh script
runsubtest                           # run xcall/ydbtypes but skip submit_test.csh: go straight to submit_subtest.csh
runscript xcall/u_inref/ydbtypes.csh # get output of a test script directly to terminal without gtmtest wrapping
```

### Viewing results

Once the test has run, you can find the results immediately in the subdirectory `$r` (typically set to `~/.results` in `.cshrc`). By way of example, you can graphically diff the most recent subtest failure using the following `difftest` alias:

```sh
alias difftest 'meld $work_dir/YDBTest/$tst/outref/$_subtest.txt $r/$subtest/$subtest.log'
```

The above also lets you conveniently merge any test differences back into the git source of your test `outref` with a few mouse clicks. (The .cshrc template has a more sophisticated example of the `difftest` alias that uses your `git config diff.tool` and lets you pass a subtest name as an optional parameter, among other things.)

As you can see, you may use the following environment variables in your own aliases:

* `$r` points to the test results directly (short name for easy access)
* `$tst` the name of the test specified by `settest -t`
* `$subtests` the space-delineated names of all subtests specified by `settest -st test1[,test2[,…]]`
* `$subtest` the last subtest listed in `$subtests` (or the last failed subtest after running `gtmtest`)

### Debugging

The `debug` alias switches on a `tcsh` tracing debugger that reports when a script invokes or sources a new script. This can be very helpful when you don't know where the bug happens. For example, to get a trace of which scripts are run:

```sh
> settest -t ydbtypes
Selecting test 'xcall', subtest 'ydbtypes' for 'runtest' to invoke. Results will go into $r
> debug
> runsubtest
   # Sourcing: $gtm_test_com_individual/tsync.csh --info=stats0,flist0 ; tcsh -fc "cd $tst_working_dir/$subtest; source $gtm_test_com_individual/submit_subtest.csh"
   # Spawning: /home/berwyn/projects/ydb/YDBTest-dev/com/tsync.csh --info=stats0,flist0
   # Spawning: /tmp/tst/T996/com/check_space.csh
...
PASS from ydbtypes
   # Spawning: /tmp/tst/T996/com/zip_output.csh /tmp/tst/tst_V996_R201_dbg_00_240510_192901/xcall_0/ydbtypes
> debug stop

```

You'll also find that when you type `debug stop` it provides an *attempt* at identifying which line numbers each script exited or produced an error (its numbering is far from perfect). Read `debug -h` for more information.

Happy debugging!

### Warnings

* Currently not all tests will run properly on the local test system, even with the `gtmtest` method. For example, none of the Go tests will run without the [YDBGo](https://gitlab.com/YottaDB/Lang/YDBGo) repository, and multi-system tests will not work without setting up a multi-system environment. Even fewer tests run when using the `settest` method, but it should be adequate for you to debug most tests.
* Be aware that the default `settest` alias switches off all randomization in order to make errors reproducible. This may mean that errors which occasionally occur with `gtmtest` will never occur with `settest`, unless you change the alias to reintroduce randomness or specifically turn on the offending setting. Random settings for `gtmtest` are defined in `YDBTest/com/do_random_settings.csh`.

## Using the Test System with Docker

The file `docker/Dockerfile` is used to build the test system and YDB for each
commit. Normally, you don't need to use it to build the test system, but can
simply pull `registry.gitlab.com/yottadb/db/ydbtest` (both AMD64 and ARM64):

```sh
docker pull registry.gitlab.com/yottadb/db/ydbtest
```

To build, you need to build from YDBTest root folder, not the docker
folder. In this example, we tag our built image to be called "registry.gitlab.com/yottadb/db/ydbtest"
(but any name would work).

```sh
docker build -f docker/Dockerfile -t registry.gitlab.com/yottadb/db/ydbtest .
```

This will build the test system with the latest master of YottaDB.

To run, you can do something like this (replacing `<local directory>` with a
suitable directory. `<local directory>` is where the artifacts will be stored
on your host when docker is finished running the test):

(In the examples below, if your Kernel is less than 5.8, you need to use
`SYS_ADMIN` instead of `PERFMON`.)

```sh
docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON --rm registry.gitlab.com/yottadb/db/ydbtest -t r200
```

The multi-host replication tests use testarea1, testarea2 and testarea3 all
together. You may need to pass additional volumes, but in the vast majority of
cases just mapping `testarea1` is enough. Here is a list of these tests:

```
gtmtest -env test_replic_mh_type=1 -t msreplic_A -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_B -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_C -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_D -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_E -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_F -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_G -replic
gtmtest -env test_replic_mh_type=1 -t msreplic_H -replic
gtmtest -env test_replic_mh_type=1 -t suppl_inst_A -replic
gtmtest -env test_replic_mh_type=1 -t suppl_inst_B -replic
gtmtest -env test_replic_mh_type=1 -t suppl_inst_C -replic
gtmtest -env test_replic_mh_type=1 -t suppl_inst_D -replic
gtmtest -env test_replic_mh_type=1 -t dualfail_ms -replic
gtmtest -env test_replic_mh_type=1 -t increment -gtcm
gtmtest -env test_replic_mh_type=1 -t increment -replic
gtmtest -env test_replic_mh_type=1 -t gtcm_gnp -gtcm
gtmtest -env test_replic_mh_type=1 -t merge -gtcm
gtmtest -env test_replic_mh_type=1 -t mem_stress -gtcm
gtmtest -env test_replic_mh_type=1 -t tcp_bkup -replic
```

The arguments after "ydbtest" are regular `gtmtest.csh` arguments. If you do
not pass any arguments, you will get the output of `gtmtest.csh -h`.

To run against a copy of YDBTest on your file system (e.g. you use it with
VSCode, and want to autoload the changes), you can do the following (the volume `-v`
argument's left hand side is the full path of the YDBTest git repository, the
right hand side of the colon is a fixed path that is known by the docker
scripts which you must not change):

```sh
docker run --init -it -v <local directory>:/testarea1/ -v <full path to YDBTest>:/YDBTest --cap-add PERFMON ---rm registry.gitlab.com/yottadb/db/ydbtest -t r200
```

To run the "sudo" subtests, you need to add extra capabilities (SYS_TIME, IPC_LOCK):

```sh
docker run --init -it -v <local directory>:/testarea1/ --rm --cap-add SYS_TIME --cap-add IPC_LOCK -registry.gitlab.com/yottadb/db/ydbtest -t sudo
```

To debug problems, instead of passing `gtmtest.csh` arguments, pass either
`-shell` to go to the `gtmtest` user id in a way so that you are ready to run tests, or
`-rootshell` to log-in as `root`. If you log-in using `-shell`, you will be given instructions
on how to a run a test. You can do that and start debugging from there.

```sh
docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON ---rm registry.gitlab.com/yottadb/db/ydbtest -shell
docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON ---rm registry.gitlab.com/yottadb/db/ydbtest -rootshell
```

To build this image with a custom version of YottaDB, clone
`https://gitlab.com/YottaDB/DB/YDB.git`, and then run the following:

```sh
# needed so the second `docker build` doesn't redownload the image each time
docker build -f docker/Dockerfile -t registry.gitlab.com/yottadb/db/ydbtest .
cd YDB
docker build -f Dockerfile-test -t ydbtestfork .
docker run --init -it -v <local directory>:/testarea1/ --cap-add PERFMON ---rm ydbtestfork -t r200
```

You can use the test system interactively inside of this docker image by supplying `-shell` at the end. You will get this message:

```
$ docker run --init --cap-add SYS_ADMIN -it -v $PWD:/YDBTest -v /testarea/sam/:/testarea1/ --rm registry.gitlab.com/yottadb/db/ydbtest -shell
Test System passed in as a volume... symlinking test system
Try running gtmtest.csh -t r134
Type 'ver' to switch versions
5c04199640f7:~> ver
Current version: V999_R999 dbg
Sets build/test environment variables to reference a database-binaries directory under $gtm_root
Usage: ver <verno> [<image>]
  where <verno> is Vxxx_Rxyz (YDB) or Vxxxxx (GT.M)
        <image> is dbg|pro|bta to select debug (default) or production images
Available versions:
        V70001_R200  pro
        V71000       pro
        V999_R999    dbg
```

You can use `ver` to switch between versions. `ver` autocompletes as well with
the tab key. 999 versions are the current master. Versions without R are GT.M
versions.

Here's an example of running a test, switching versions, and running that test with the new version:

```
$ docker run --init --cap-add SYS_ADMIN -it -v $PWD:/YDBTest -v /testarea/sam/:/testarea1/ --rm registry.gitlab.com/yottadb/db/ydbtest -shell
Test System passed in as a volume... symlinking test system
Try running gtmtest -t r134
Type 'ver' to switch versions
7daa11820f88:~> gtmtest -t r134
Created /testarea1/tst_V999_R999_dbg_01_241011_180745_zgF
Test Version            :: V999_R999
Test Image              :: dbg
Test Mail List          :: gtmtest
Test Output Directory   :: /testarea1/tst_V999_R999_dbg_01_241011_180745_zgF
Test Source Directory   :: T999

r134 test starts...
PASS from ydb757
PASS from ydb775
PASS from ydb782
PASS from ydb772
PASS from ydb785
PASS from ydb734
PASS from ydb828
PASS from ydb831
PASS from ydb555
PASS from ydb546
PASS from ydb758
PASS from ydb557
PASS from ydb840
PASS from ydb781
PASS from ydb846
PASS from ydb845
r134 test DONE.
00:00:00:46
Fri Oct 11 06:08:32 PM UTC 2024 PASSED r134
7daa11820f88:~> ver
Current version: V999_R999 dbg
Sets build/test environment variables to reference a database-binaries directory under $gtm_root
Usage: ver <verno> [<image>]
  where <verno> is Vxxx_Rxyz (YDB) or Vxxxxx (GT.M)
        <image> is dbg|pro|bta to select debug (default) or production images
Available versions:
        V70001_R200  pro
        V71000       pro
        V999_R999    dbg
7daa11820f88:~> ver V70001_R200 p
        $gtm_dist set to /usr/library/V70001_R200/pro
7daa11820f88:~> gtmtest -t r134
Created /testarea1/tst_V70001_R200_pro_01_241011_180906_AxL
Test Version            :: V70001_R200
Test Image              :: pro
Test Mail List          :: gtmtest
Test Output Directory   :: /testarea1/tst_V70001_R200_pro_01_241011_180906_AxL
Test Source Directory   :: T999

r134 test starts...
PASS from ydb757
PASS from ydb775
PASS from ydb782
PASS from ydb772
PASS from ydb785
PASS from ydb734
PASS from ydb828
PASS from ydb831
PASS from ydb555
PASS from ydb546
PASS from ydb758
PASS from ydb557
PASS from ydb840
PASS from ydb781
PASS from ydb846
PASS from ydb845
r134 test DONE.
00:00:00:50
Fri Oct 11 06:09:56 PM UTC 2024 PASSED r134
```

## Running Test pipelines
This command is for you to troubleshoot `docker/pipeline-test-ydbtest.csh` (used in the YDBTest pipeline) locally. It's tricky to construct:
```
docker run --init --cap-add SYS_ADMIN --cap-add SYS_TIME -it -v $PWD:/YDBTest -v /testarea/sam/:/testarea1/ --rm -w /YDBTest --entrypoint docker/pipeline-test-ydbtest.csh registry.gitlab.com/yottadb/db/ydbtest
```

To troubleshoot `docker/pipeline-test-ydb.csh` (used in the YDB pipeline), run either of the following:

1. To troubleshoot the script itself, run this:
```
docker run --init --cap-add SYS_ADMIN --cap-add SYS_TIME -e CI_COMMIT_BRANCH=master -it [-v $PWD:/YDBTest] -v ~/work/gitlab/YDB:/builds/shabiel/YDB -v /testarea/sam/:/testarea1/ --rm -w /builds/shabiel/YDB --entrypoint /usr/library/gtm_test/T999/docker/pipeline-test-ydb.csh registry.gitlab.com/yottadb/db/ydbtest
```

2. To replicate the YDB pipeline, go to YDB repo and run these steps:
```
docker build -f Dockerfile-test -t ydbtest .
docker run --init --cap-add SYS_ADMIN --cap-add SYS_TIME -it -v /testarea/sam/:/testarea1/ --rm --entrypoint /usr/library/gtm_test/T999/docker/pipeline-test-ydb.csh ydbtest
```

## Troubleshooting

If gtmtest gives the following error, you may need to turn off the sticky bit on the given path with `chmod -x <path>`:

```
YDB-MUMPS[23439]: %YDB-E-INVLINKTMPDIR, Value for $ydb_linktmpdir/$gtm_linktmpdir is either not found or not a directory(/tmp/relinkdir/yourname) - Reverting to default value -- generated from 0x00007F15E3CED431.
```

# Making new tests

The YottaDB developers have adopted the following de-facto standard for naming new tests and MRs. This is non-binding if you have a reason to buck the trend:

**Test names** are of the form `<test>/<subtest>`, where:

* This maps to directory path: `YDBTest/<test>/u_inref/<subtest>.csh`
* `<test>` should name the version of YDB (rXYY) or GT.M (vXYZZZ) that introduced the feature under test (without punctuation, and lower case). Unless it is a major feature, in which case a more human name may be used.
* `<subtest>` should be in the form `<human_name>-<feature_issue>`, where:
  * `human_name` should be short: words separated by underscores
  * `<feature_issue>` should be the YDB or GT.M issue number that *first* recorded added this feature or change (without punctuation, and lower case).
  * `YDBTest/<test>/instream.csh` should have a comment line at the start, of the form:
      `# <subtest>                     [author] Description of test`
  * `<subtest>` should ideally be 29 or less characters (to align tab stops in `instream.csh` comments, if alignment desired).

**MR titles** for a new test should be of the form `[<issue>] New <test>/<subtest> <description>`, where:

* `<issue>` is preferably `#num` to supply the YDBTest issue number (or, failing that, `YDB#num`) of the issue addressed by this MR.
* the word 'New' will obviously not be included when the MR is a fix for an existing test.
* `<test>/<subtest>` is as specified above.

## Examples

| Test Names                    | MR titles                                                    |
| ----------------------------- | ------------------------------------------------------------ |
| r200/tcp_listen-ydb996        | [YDB#996] New r140/tcp_listen-ydb996 subtest to test that LISTENING TCP sockets can be passed |
| v70003/mupip_order-gtmf134692 | [#596] New v70003/mupip_order-gtmf134692 to test MUPIP INTEG / MUPIP DUMPFHEAD user-specified region order |
