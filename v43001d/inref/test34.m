test34	;
	; test that ecodes that get added after 32 overwrite the 32nd ecode
x       ;
        set num=0
        set count=0
        set $ztrap="do ztr"
        set $ecode=",M"_num_","
        quit
ztr     ;
        write $ecode,!
        set count=count+1
        set num=num+1
        if num>145 set $ztrap="goto ztr"
        if count>35 set $ecode="",count=0
        quit
