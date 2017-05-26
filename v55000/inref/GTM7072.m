;
; GTM7072.m - Should be run with $gtm_ztrap_form set to entryref. Yes, the
;             error traps aren't set up for it but that's what generated the
;             assert failure prior to V55000.
;
FREAD
        read "File > ",sd
        set retry=0
        set $ztrap="do BADOPEN" ; an entryref does not 
        open sd:(readonly)
        use sd:exception="goto EOF"
        for  use sd read x use $principal write x,!
EOF
        if '$zeof zmessage +$zstatus
        close sd
        quit

BADOPEN
        set retry=retry+1
        ;if retry=4 halt ; to prevent stack overflow
        if $piece($zstatus,",",1)=2 do
        . write !,"The file ",sd," does not exist. Retrying ..."
        . hang 2
        . quit
        if $piece($zstatus,",",1)=13 do
       . write !,"The file ",sd," is not accessible. Retrying ..."
        . hang 3
        . quit
        quit

BADAGAIN
        w !,"BADAGAIN",!
