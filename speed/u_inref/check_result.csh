#!/usr/local/bin/tcsh -f
#
### Following is for computing speed test reference speed from ^run number of runs
###
$gtm_tst/$tst/u_inref/compute_ref.csh >>& compute_ref.log 
\mv  primsize.m primsize.save
\mv -f *.m ../
#
#save the results to logs directory
if !($?test_dont_log) then
        set timestamp = `date +%Y%m%d_%H%M%S`
        set server = "$HOST:r:r"
        set save_dir = $gtm_test_log_dir/$server
        if (! -d $save_dir) then
                mkdir -p $save_dir
                if ($status) then
                        echo "TEST-E-LOGDIR, Could not create log directory $save_dir"  >>! $tst_general_dir/outstream.log
		else
			chmod 775 $save_dir
                endif
        endif
        if (! -w $save_dir) then
                echo "TEST-E-LOG, Do not have write permission to log directory $save_dir" >>! $tst_general_dir/outstream.log
        endif
        cp -p $tst_general_dir/result.txt $save_dir/result_${timestamp}_${gtm_verno}.txt
        cp -p $tst_general_dir/sp_data.txt $save_dir/sp_data_${timestamp}_${gtm_verno}.txt
endif
echo "Speed Test Ends..."
