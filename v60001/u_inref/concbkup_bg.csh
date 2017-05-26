#!/usr/local/bin/tcsh -f

@ count = 1
mkdir backup_bg
@ max_conc_bkups = 1000
while ( $count <= $max_conc_bkups )
	rm backup_bg/* >&! delete_bg.log
        $MUPIP backup "*" backup_bg/ >&! backup_bg_$count.logx
        $grep "BKUPRUNNING" backup_bg_$count.logx
        if ( 0 == $status ) then
                $gtm_exe/mumps -run %XCMD 'set ^ready=1'
                break
        else
                @ ready = `$gtm_exe/mumps -run %XCMD 'w ^ready'` 
                if ( 1 == $ready) then
                        break
                endif
        if ( 1000 == $count ) then
		break
        endif
	@ count = $count + 1
end
