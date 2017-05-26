v4v5obj(localvar);
        write "localvar value passed is 1 & its cumulative product for 25 times is",!
        for counter=1:1:25 do
        . set localvar=counter*localvar
        . write "localvar = ",localvar,!
        write "routine execution ends at "
        write $ZDATE($H,"YEAR-MM-DD 24:60:SS")
        quit
