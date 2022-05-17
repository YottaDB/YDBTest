# YottaDB Test System

All software in this package is part of YottaDB (<https://yottadb.com>) each
file of which identifies its copyright holders. The software is made available
to you under the terms of a license. Refer to the [LICENSE](LICENSE) file for details.

Homepage: <https://gitlab.com/YottaDB/DB/YDB>

Documentation: <https://yottadb.com/resources/documentation/>


# Overview

Documentation on usage is under development as time permits and will be released from time to time. For the present, please read the shell scripts. The .csh files are shell scripts written for the tcsh shell. There is now a Dockerfile, and that is probably the easiest way to run the test system. The instructions are at the bottom of this README.

## Pre-commit hooks

To install the pre-commit hooks, run the following:

```sh
ln -s ../../pre-commit .git/hooks
```

## License

If you receive this package integrated with a YottaDB distribution, the license for your YottaDB regression test suite is that of YottaDB under the terms of its license.

Simple aggregation or bundling of this package with another for distribution does not create a derivative work. To make clear the distinction between this package and another with which it is aggregated or bundled, it suffices to place the package in a separate directory or folder when distributing the aggregate or bundle.

Should you receive this package not integrated with a YottaDB distribution, and missing a COPYING file, you may create a file called COPYING from the GNU Affero General Public License Version 3 or later (<https://www.gnu.org/licenses/agpl.txt>) and use this package under the terms of that license.

## Pre-requisites

The following binaries are required to run the test system:

- ksh
- gawk
- sed
- lsof
- bc
- sort
- fuser
- strace
- expect
- eu-elflint
- netstat
- nc
- gdb

Currently tcsh is the only supported shell, make sure that tcsh is properly installed and that you can switch to it with the following command:

```sh
tcsh
```

A symbolic link of tcsh is also needed in the local bin

```sh
sudo ln -s /usr/bin/tcsh /usr/local/bin/tcsh
```

Make a directory to store all YottaDB related files taken from the repository

```sh
sudo mkdir /testing
```

## Environment variables

Create or edit the `.cshrc` file inside your home directory and add the following lines:

```csh
set autolist
set backslash_quote
set dextract
set dunique
set filec
set history=10000
set lineedit
set matchbeep=nomatch
set savehist
setenv LC_ALL_C
unset autologout
unset glob

alias s 'source ${HOME}/.cshrc-int'
alias S s

set HOST=$HOST:r
setenv HOST $HOST:r
```

Create a `.cshrc-int` file inside the home directory with the following lines.

```csh
setenv mailid user@mail.com # Replace with your email here

setenv verno R133
setenv gtm_root /usr/library	# Can be replaced with any directory
setenv gtm_test $gtm_root/gtm_test
setenv ydb_dist $gtm_root/$verno/pro
setenv gtm_dist $ydb_dist
setenv gtm_exe $gtm_dist ; setenv gtmroutines ". $gtm_dist"
setenv gtm_tools $gtm_root/$verno/tools
setenv gtm_inc $gtm_root/$verno/inc
setenv gtm_source $gtm_root/$verno/src
setenv gtm_verno $verno
setenv gtm_ver $gtm_root/$verno
setenv gtm_obj $gtm_exe/obj
setenv gtm_log $gtm_ver/log
setenv gtm_testver T133
setenv gtm_curpro $verno
setenv gtm_com ""
setenv gtm_icu_version `pkg-config --modversion icu-io`
setenv tst_dir /testarea1	# Can be replaced with any directory

alias gtmtest $gtm_test/$gtm_testver/com/gtmtest.csh -report on -noencrypt -env eall_noinverse=1 $*
```

## Install YottaDB

Instructions to install YottaDB: <https://gitlab.com/YottaDB/DB/YDB/-/blob/master/README.md>

Before installing YottaDB, create a directory to store the build inside `$gtm_root`:

```sh
cd $gtm_root
sudo mkdir $verno ; cd $verno
sudo mkdir dbg pro
```

Install the pro version in `$gtm_root/$verno/pro` and the dbg version in `$gtm_root/$verno/dbg`

## Getting the YDBTest repository

Go into `$gtm_root` and create the `gtm_test` directory where the files for the test repository will be stored

```sh
cd $gtm_root
sudo mkdir gtm_test ; cd gtm_test
sudo mkdir T133
```

Create a simple script within the `testing` directory that will sync files to the specified test version

```sh
$ cat testing/synctest
#!/usr/bin/tcsh -f
if ("" == "$1") then
        echo "missing Test directory to sync"
        exit 1
endif
if (! -e $gtm_test/$1) then
        echo "Test library $gtm_test/$1 does not exist"
        exit 1
endif
sudo rsync -av --delete /testing/YDBTest/ $gtm_test/$1 # Change to wherever YDBTest repository is stored
```

Get a clone of the YDBTest repository:

```sh
git clone https://gitlab.com/YottaDB/DB/YDBTest.git
```

Before syncing the test repository, the system log file is not needed to run tests locally, any reference to it should be commented out or removed

```sh
cat testing/YDBTest/com/check_setup_dependencies.csh
...
# make sure system log file is readable
#set syslog_file=`$grep -v '^#' $gtm_test_serverconf_file | $tst_awk '$1 == "'$hostn'" {print $8}'`
#if ("" == $syslog_file) then
#	echo "TEST-E-UTILITY problem getting system log file for $hostn from $gtm_test_serverconf_file ;"
#	@ error++
#else
#	if (! -r $syslog_file) then
#		echo "TEST-E-UTILITY $syslog_file is not readable ;"
#		@ error++
#	endif
#endif
#endif
...
```

Now the test repository can be synced

```sh
../synctest T133
```

## Setting up the build

Make sure to switch to tcsh. If you recently created or edited your `.cshrc` file, make sure you start a new tcsh shell. Then run the following command to set the environment variables in your `.cshrc-int` file:

```sh
S
```

Create and run a `build.csh` file in the parent directory of your local YDB repository.

```csh
#!/usr/bin/tcsh
if (! -d $gtm_dist/obj) then
        set sudostr = "sudo mkdir $gtm_dist/obj"
        $sudostr
        @ status1 = $status
if ($status1) then
        echo "BUILDREL_IMAGE_COMMON-E-SUDOFAIL : $sudostr failed with status = $status1. Exiting..."
        exit -1
        endif
endif
cp -pa YDB/cmake/*.a $gtm_obj/

if (! -d $gtm_ver/tools) then
        set sudostr = "sudo mkdir $gtm_ver/tools"
        $sudostr
        @ status1 = $status
        if ($status1) then
                echo "BUILDREL_IMAGE_COMMON-E-SUDOFAIL : $sudostr failed with status = $status1. Exiting..."
                exit -1
        endif
endif
set sudostr = "sudo chown $user.gtc $gtm_ver/tools"
$sudostr
cp -pa YDB/sr_unix/*.awk $gtm_tools/
cp -pa YDB/sr_unix/*.csh $gtm_tools/
cp -pa YDB/sr_linux/*.csh $gtm_tools/
rm -f $gtm_ver/tools/setactive{,1}.csh

# This may need to be `uname -i` instead depending upon your machine or you can hardcode
# it to x86_64, aarch64, armv6l or armv7l as appropriate. This is needed to ensure that
# the correct assembly code is used to build YottaDB.
set machtype=`uname -m`
foreach ext (c s msg h si)
        if (($ext == "h") || ($ext == "si")) then
                set dir = "inc"
        else
                set dir = "src"
        endif
        if (! -d $gtm_ver/$dir) then
                set sudostr = "sudo mkdir $gtm_ver/$dir"
                $sudostr
                @ status1 = $status
                if ($status1) then
                        echo "BUILDREL_IMAGE_COMMON-E-SUDOFAIL : $sudostr failed with status = $status1. Exiting..."
                        exit -1
                endif
        endif
        set sudostr = "sudo chown $user.gtc $gtm_ver/$dir"
        $sudostr
        @ status1 = $status
        if ($status1) then
                echo "BUILDREL_IMAGE_COMMON-E-SUDOFAIL : $sudostr failed with status = $status1. Exiting..."
                exit -1
        endif
        cp -pa YDB/sr_port/*.$ext $gtm_ver/$dir/
        cp -pa YDB/sr_port_cm/*.$ext $gtm_ver/$dir/
        cp -pa YDB/sr_unix/*.$ext $gtm_ver/$dir/
        cp -pa YDB/sr_unix_cm/*.$ext $gtm_ver/$dir/
        cp -pa YDB/sr_unix_gnp/*.$ext $gtm_ver/$dir/
        if (${machtype} == "x86_64") then
                cp -pa YDB/sr_x86_regs/*.$ext $gtm_ver/$dir/
        endif
        cp -pa YDB/sr_${machtype}/*.$ext $gtm_ver/$dir/
        cp -pa YDB/sr_linux/*.$ext $gtm_ver/$dir/
end
```

## Create output directory

Before the test system can be run, the output needs to be stored in an output directory. Create an output directory with the proper permissions:

```sh
mkdir /testarea1	# The name of this directory should be the same as whatever $tst_dir is set to
cd /testarea1 ; sudo mkdir $user
sudo chown -R $user.gtc $user
```

## Running a test
To run a test make sure that the shell is `tcsh` and source `.cshrc-int` with `s`

Run a test by using `gtmtest`. The following arguments are needed to run the gtmtest properly:

1. `-s`: Calls a specific test version's `gtmtest.csh`
2. `-t`: Tells the test system to run a specific test
3. `-st`: An optional argument that will run a specific subtest
4. `-replic`: An optional argument that runs the test with replication turned on

An example of how to run the test system

```sh
gtmtest -s T133 -t basic
gtmtest -s T133 -t basic -replic
```

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

### Warnings

Currently not all tests will run properly on the local test system. For example none of the Go tests will run without the [YDBGo] repository and multi-system tests will not work without setting up a multi-system environment.

[YDBGo]: https://gitlab.com/YottaDB/Lang/YDBGo

## Docker Set-up
To build, you need to build from YDBTest root folder, not the docker
folder. In this example, we tag our built image to be called "ydbtest".

```sh
docker build -f docker/Dockerfile -t ydbtest .
```

To run, you can do something like this (replacing `<local directory>` with a
suitable directory. `<local directory>` is where the artifacts will be stored
on your host when docker is finished running the test.):

```sh
docker run --init -it -v <local directory>:/testarea1/ --rm ydbtest -t r132
```

The arguments after "ydbtest" are regular `gtmtest.csh` arguments. If you do
not pass any arguments, you will get the output of `gtmtest.csh -h`.

To run against a copy of YottaDB on your file system, you can do this; the
volume (-v) argument left hand side is the full path of the YDB git repository
whose source code would be used to build YottaDB, the right hand side of the
colon is a fixed path that is known by the docker scripts which you must not
change:

```sh
docker run --init -it -v <full path to YottaDB>:/YDB/ -v <local directory>:/testarea1/ --rm ydbtest -t r132
```

To run against a copy of YDBTest on your file system, you can do this; the
volume (-v) argument left hand side is the full path of the YDBTest git repository
whose source code would be used to build YottaDB, the right hand side of the
colon is a fixed path that is known by the docker scripts which you must not
change:

```sh
docker run --init -it -v <local directory>:/testarea1/ -v <full path to YDBTest>:/YDBTest --rm ydbtest -t r132
```

You can combine the latter two options, to both pass a YottaDB source and a
YDBTest source on your file system.

To debug problems, instead of passing `gtmtest.csh` arguments, pass either
`-shell` to go to the `gtmtest` user id in a way so that you are ready to run tests, or
`-rootshell` to log-in as `root`.

```sh
docker run --init -it -v <local directory>:/testarea1/ --rm ydbtest -shell
docker run --init -it -v <local directory>:/testarea1/ --rm ydbtest -rootshell
```
