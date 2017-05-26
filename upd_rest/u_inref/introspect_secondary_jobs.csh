#!/usr/local/bin/tcsh

set updprcpid = $1
echo "==> Update process PID is $updprcpid"
echo
cd $SEC_SIDE
#
echo "==> Waiting for the job processes to start on the secondary (date is `date`) "
while (1)
	set nmjo = `ls -l *.mjo* | wc -l`
	if (6 == $nmjo) then
		break
	endif
	sleep 1
end
#
echo
echo "==> Waiting for PID to be printed on the mjo files (date is `date`)"
#
while (1)
	set npid = `cat *.mjo* | $grep PID | $tst_awk '{print $NF}' | wc -l`
	if (6 == $npid) then
		break
	endif
	sleep 1
end
#
echo
echo "==> All jobs started on the secondary (date is `date`). Below is the list of the mjo files"
ls -l *.mjo*
echo

#
set arr = (`cat *.mjo* | $grep PID | $tst_awk '{print $NF}'`)
set arrlen = $#arr
echo "==> arr = $arr"
echo "==> arrlen = $arrlen"
echo
while (1)
	set jobs_completed = 0
	set iter = 1
	# Get the stack trace of the jobbed off M process in the secondary
	while ($iter <= $arrlen)
		set pid = $arr[$iter]
		$gtm_tst/com/is_proc_alive.csh $pid
		if ($status) then
			echo
			echo "==> $pid already completed"
			echo
			@ jobs_completed = $jobs_completed + 1
			@ iter = $iter + 1
		else
			$echoline >>&! introspect_$pid.out
			date >>&! introspect_$pid.out
			$gtm_tst/com/get_dbx_c_stack_trace.csh $pid $gtm_exe/mumps >>&! introspect_$pid.out
			date >>&! introspect_$pid.out
			$echoline >>&! introspect_$pid.out
			echo >>&! introspect_$pid.out
			$gtm_tst/com/check_PC_INVAL_err.csh $pid introspect_$pid.out
			@ iter = $iter + 1
		endif
	end
	# Now get the stack trace of the update process' PID
	$gtm_tst/com/is_proc_alive.csh $updprcpid
	if ($status) then
		echo
		echo "==> Update process' PID $updprcpid does NOT exist anymore. This is not expected"
		echo
	else
		$echoline >>&! introspect_updproc.out
		date >>&! introspect_updproc.out
		$gtm_tst/com/get_dbx_c_stack_trace.csh $updprcpid $gtm_exe/mupip >>&! introspect_updproc.out
		date >>&! introspect_updproc.out
		$echoline >>&! introspect_updproc.out
		echo >>&! introspect_updproc.out
		$gtm_tst/com/check_PC_INVAL_err.csh $updprcpid introspect_updproc.out
	endif
	if ($arrlen == $jobs_completed) then
		break
	endif
	sleep 10
end
echo
echo "==> Now the date is `date`"
