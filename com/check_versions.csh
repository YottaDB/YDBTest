#! /usr/local/bin/tcsh -f
#
# the script loops thro' an older set of versions as specified in the version_list by the caller &
# executes the test scrpt specified with that older version
# version_list is an env. variable set by the caller
#
# usage:
# $gtm_tst/com/check_versions.csh testname reference_file
# testname should be as in u_inref & reference_file should be as in u_outref.
# The testname which the user specifies would then be executed taking one argument which is the chosen old version.
#
if (("" == "$1") || ("" == "$2")) then
        echo "Please specify the test name to execute & its reference file"
 	echo "usage:"
        echo "$gtm_tst/com/check_versions.csh testname reffile"
        exit 1
endif
# basename is just to ensure user can call with/without extensions
set script = `basename $1 .csh`
set reffile = `basename $2 .txt`
set errcnt = 0
foreach ver ($version_list)
        $gtm_tst/$tst/u_inref/$script.csh $ver >&! $ver.log
        set stat = $status
        if ($stat) then
                echo "-------------------------------------------------------------"
                echo "TEST-E-$testname version $ver returned $stat status."
                echo "Please check the output at $ver.log"
                @ errcnt = $errcnt + 1
                echo "-------------------------------------------------------------"
        endif
        # check output
        $gtm_tst/com/check_reference_file.csh $gtm_tst/$tst/outref/$reffile.txt $ver.log
        set stat = $status
        if ($stat) then
                echo "-------------------------------------------------------------"
                echo "TEST-E-$testname FAIL from $script for version $ver"
                echo "Please check $ver.diff"
                @ errcnt = $errcnt + 1
                echo "-------------------------------------------------------------"
	else
		$tst_gzip $ver.log
        endif
end
if (0 == $errcnt) then
        echo "PASS"
else
        echo "FAIL"
endif
