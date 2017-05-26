gtm7495	;
        s X=$ZTRIGGER("ITEM","+^SAMPLE -commands=S -xecute=""w ^SAMPLE,!"" -name=myname0")
        write "Executing ^SAMPLE=1",! set ^SAMPLE=1
        write "Executing ^SAMPLE=2",! set ^SAMPLE=2
        write "Executing ^SAMPLE=3",! set ^SAMPLE=3
        do ^job("child^gtm7495",1,"""""")
        write "Executing ^SAMPLE=4",! set ^SAMPLE=4
        write "Executing ^SAMPLE=5",! set ^SAMPLE=5
        write "Executing ^SAMPLE=6",! set ^SAMPLE=6
        quit
child   ;
        s X=$ztrigger("ITEM","-*")
        quit
