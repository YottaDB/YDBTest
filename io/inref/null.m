NULL    SET hdr="HEADER"
        SET unix=$ZVERSION'["VMS"
        IF unix SET dev="/dev/null"
        ELSE  SET dev="nl:"
        OPEN dev USE dev
        SET x="" WRITE hdr,!,$ZDATE($h),?30,$J,!
        FOR  SET x=$O(^tmp($J,x)) q:x=""  DO REPORT
        CLOSE dev
        QUIT
REPORT  WRITE "BLAH BLAH BLAH"
	WRITE $$^longstr(35000)
