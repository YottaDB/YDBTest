start ;
 job showcmd:(err="err1.out":out="cmd1.out":cmd="first job process")
 for  set childalive=$$^isprcalv($zjob) quit:'childalive

showcmd
 write $zcmdline,!
 zsystem "ps -p "_$job_" -f|grep mumps"
 job showcmdagain:(err="err2.out":out="cmd2.out")
 for  set childalive=$$^isprcalv($zjob) quit:'childalive
 quit

showcmdagain
 write $zcmdline,!
 zsystem "ps -p "_$job_" -f|grep mumps"
 job showcmd3rd:(err="err3.out":out="cmd3.out":cmd="third job process")
 for  set childalive=$$^isprcalv($zjob) quit:'childalive
 quit

showcmd3rd
 write $zcmdline,!
 zsystem "ps -p "_$job_" -f|grep mumps"
 quit

halt
