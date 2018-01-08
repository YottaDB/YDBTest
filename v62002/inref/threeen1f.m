;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017,2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
threeen1f
        ; Find the maximum number of steps for the 3n+1 problem for all integers through two input integers.
        ; See http://docs.google.com/View?id=dd5f3337_24gcvprmcw
        ; Assumes input format is 3 integers separated by a space with the first integer smaller than the second.
        ; The third integer is the number of parallel computation streams.  If it is less than twice the
        ; number of CPUs or cores, the parameter is modified to that value.  An optional fourth integer is the
        ; sizes of blocks of integers on which spawned child processes operate.  If it is not specified, the
        ; block size is approximately the range divided by the number of parallel streams.  If the block size is
        ; larger than the range divided by the number of execution streams, it is reduced to that value.
        ; No input error checking is done.

        ; Although the problem can be solved by using strictly integer subscripts and values, this program is
        ; written to show that the GT.M key-value store can use arbitrary strings for both keys and values -
        ; each subscript and value is spelled out using the strings in the program source line labelled "digits".
        ; Furthermore, the strings are in a number of international languages when GT.M is run in UTF-8 mode.

        ; K.S. Bhaskar 2010612

        ; No claim of copyright is made with respect to this program.

        ; Variables do not have to be declared before use, but are New'd in subprograms to ensure that they
        ; do not conflict with names in the caller.

        ; The program reads the program source at the label digits to get strings (separated by ;) for each language used.
digits  ;zero;eins;deux;tres;quattro;пять;ستة;सात;捌;ஒன்பது
        Do digitsinit                           ; Initialize data for conversion between integers and strings

        ; Get number of CPUs from /proc/cpuinfo and calculate minimum number of execution streams
        Open "cpus":(SHELL="/bin/sh":COMMAND="grep -i ^processor /proc/cpuinfo|wc -l":READONLY)::"PIPE"
        Use "cpus" Read streams Use $PRINCIPAL
        Close "cpus"
        Set streams=2*streams                   ; At least two execution streams per CPU

        ; At the top level, the program reads and processes input lines, one at a time.  Each line specifies
        ; one problem to solve.  Since the program is designed to resume after a crash and reuse partial
        ; results computed before the crash, data in the database at the beginning is assumed to be partial
        ; results from the previous run.  After computing and writing results for a line, the database is
        ; cleared for next line of input or next run of the program.

        ; Loop for ever, read a line (quit on end of file), process that line
        For  Read input Quit:$ZEOF!'$Length(input)  Do      ; input has entire input line
        .
        . Set i=$Piece(input," ",1)                         ; i - first number on line is starting integer for the problem
        . Set j=$Piece(input," ",2)                         ; j - second number on line is ending integer for the problem
        . Write $FNumber(i,",",0)," ",$FNumber(j,",",0)     ; print starting and ending integers, formatting with commas
        .
        . Set k=$Piece(input," ",3)                         ; k - third number on input line is number of parallel streams
        . If streams>k Do                                   ; print number of execution streams, optionally corrected
        ..  Write " (",$FNumber(k,",",0)
        ..  Set k=streams
        ..  Write "->",$FNumber(k,",",0),")"
        . Else  Write " ",$FNumber(k,",",0)
        .
        . Set blk=+$Piece(input," ",4)                          ; blk - size of blocks of integers is optional fourth piece
        . Set tmp=(j-i+k)\k                                     ; default / maximum block size
        . If blk&(blk'>tmp) Write " ",$FNumber(blk,",",0)       ; print block size, optionally corrected
        . Else  Do
        ..  Write " (",$FNumber(blk,",",0)
        ..  Set blk=tmp
        ..  Write "->",$FNumber(blk,",",0),")"
        .
        . ; Define blocks of integers for child processes to work on
        . Kill ^limits
        . Set tmp=i-1
        . For count=1:1 Quit:tmp=j  Do
        ..  Set ^limits(count)=$increment(tmp,blk)
        ..  Set:tmp>j (tmp,^limits(count))=j
        .
        . ; Launch jobs.  Grab lock l1, atomically increment counter, compute and launch one job for each block of numbers.
        . ; Each child job locks l2(pid), decrements the counter and tries to grab lock l1(pid).
        . ; When counter is zero, all jobs have started.  Parent releases lock l1 and tries to grab lock l2.
        . ; When all children have released their l2(pid) locks, they're done and parent can gather & report results.
        . Set ^count=0                                  ; Clear ^count - may have residual value if restarting from crash
        . Lock +l1                                      ; Set lock for process synchronization
        . For s=1:1:k Do
        ..  Set c=$Increment(^count)                    ; Atomic increment of counter in database for process synchronization
        ..  Set def=$ZTRNLNM("gtm_tmp") Set:'$Length(def) def=$ZTRNLNM("PWD")     ; Working directory for Jobbed process
        ..  Set err=$Text(+0)_"_"_$Job_"_"_s_".mje"                               ; STDERR for Jobbed process
        ..  Set out=$Extract(err,1,$Length(err)-1)_"o"                            ; STDOUT for Jobbed process
        ..  Set cmd="doblk(i):(ERROR="""_err_""":OUTPUT="""_out_""":DEFAULT="""_def_""")"     ; Command to Job
        ..  Job @cmd				; Job child process for next block of numbers
	..  set childpid(s)=$zjob		; Note down child pids
        . For i=1:1:3000 Quit:'^count  Hang 0.1  ; Wait up to 5 minutes for processes to start (^count goes to 0 when they do)
	. if ^count write !,^count," jobs did not start"
        . Lock -l1                               ; Release lock so processes can run
        . Set startat=$HOROLOG                   ; Get starting time
        . Lock +l2:$select($ztrnlnm("gtm_poollimit"):900,1:600)   ; Wait for processes to finish (may take longer with a poollimit)
        . else  kill ^limits write !,"some jobs have not finished in 10 minutes"
        .
        . ; When parent gets lock l2, child processes have completed and parent gathers and reports results.
        . set endat=$HOROLOG                     ; Get ending time - time between startat and endat is the elapsed time
        . ; Calculate duration
        . Set duration=(86400*($Piece(endat,",",1)-$Piece(startat,",",1)))+$Piece(endat,",",2)-$Piece(startat,",",2)
        . Write " ",$FNumber(^result,",",0)     ; Show largest number of steps for the range i through j
        . Write " ",$FNumber(^highest,",",0)    ; Show the highest number reached during the computation
        . Write " ",$FNumber(duration,",",0)    ; Show the elapsed time
        . Write " ",$FNumber(^updates,",",0)    ; Show number of updates
        . Write " ",$FNumber(^reads,",",0)      ; Show number of reads
        . ; If duration is greater than 0 seconds, display update and read rates
        . Write:duration " ",$FNumber(^updates/duration,",",0)," ",$FNumber(^reads/duration,",",0)
        . Write !
        . Lock -l2                               ; Release lock for next run
	. ; Wait for child processes to terminate before moving on to next run
        . For s=1:1:k do ^waitforproctodie(childpid(s),300)
        . Do dbinit                              ; Initialize database for next run
        Quit

dbinit  ; Entryref dbinit clears database between lines
        Set (^count,^highest,^reads,^result,^step,^updates)=0
        Quit

digitsinit                                      ; Initialize arrays to convert between strings and integers
        New m,x
        Set x=$Text(digits)
        For m=0:1:9 Set di($Piece(x,";",m+2))=m,ds(m)=$Piece(x,";",m+2)
        Quit

inttostr(n)                                     ; Convert an integer to a string
        New m,s
        Set s=ds($Extract(n,1))
        For m=2:1:$Length(n) Set s=s_" "_ds($Extract(n,m))
        Quit s
        ;
strtoint(s)                                     ; Convert a string to an integer
        New m,n
        Set n=di($Piece(s," ",1))
        For m=2:1:$Length(s," ") Set n=10*n+di($Piece(s," ",m))
        Quit n

; This is where Jobbed processes start
doblk(allfirst)
        Set (reads,updates,highest)=0           ; Start with zero reads, writes and highest number
        Do digitsinit                           ; Initialize data for conversion between integers and strings
        Lock +l2($JOB)                          ; Get lock l2 that parent will wait on till this Jobbed processes is done
        If $Increment(^count,-1)                ; Decrement ^count to say this process is alive
        Lock +l1($JOB)                          ; This process will get lock l1($JOB) only parent has released lock on l1
        ;
        ; Process the next block in ^limits that needs processing; quit when done
        For  Quit:'$Data(^limits($increment(tmp)))  Do:1=$increment(^limits(tmp,1)) dostep($select($data(^limits(tmp-1)):^limits(tmp-1)+1,1:allfirst),^limits(tmp))
        ;
        TStart ()                               ; Update global statistics inside a transaction
        ; The following line unconditionally adds the number of reads & write performed by this process to the
        ; number of reads & writes performed by all processes, and sets the highest for all processes if the
        ; highest calculated by this process is greater than that calculated so far for all processes
        Set:$Increment(^reads,reads)&$Increment(^updates,updates)&(highest>$Get(^highest)) ^highest=highest
        TCommit
        Lock -l1($JOB),-l2($JOB)                ; Release locks to tell parent this parent is done
        Quit                                    ; Jobbed processes terminate here

dostep(first,last)                              ; Calculate the maximum number of steps from first through last
        New current,currpath,i,n
        For current=first:1:last Do
        . Set n=current                          ; Start n at current
        . Kill currpath                          ; Currpath holds path to 1 for current
        . ; Go till we reach 1 or a number with a known number of steps
        . For i=0:1 Quit:$Increment(reads)&($Data(^step($$inttostr(n)))!(1=n))  Do
        ..  Set currpath(i)=n                     ; log n as current number in sequence
        ..  Set n=$Select('(n#2):n/2,1:3*n+1)     ; compute the next number
        ..  Set:n>highest highest=n             ; see if we have a new highest number reached
        . Do:0<i                                 ; if 0=i we already have an answer for n, nothing to do here
        ..  If 1<n Set i=i+$$strtoint(^step($$inttostr(n)))
        ..  TStart ()                             ; Atomically set maximum
        ..  Set:i>$Get(^result) ^result=i
        ..  TCommit
        ..  Set n="" For  Set n=$Order(currpath(n)) Quit:""=n  Set:$Increment(updates) ^step($$inttostr(currpath(n)))=$$inttostr(i-n)
        Quit
