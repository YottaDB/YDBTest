memstat ; 
     SET file=$ZCMDLINE
    OPEN file
     USE file
     SET total=0
     FOR  q:$zeof=1  do
        . READ line
        . SET total=total+line 
   CLOSE file
   WRITE total,!
    QUIT

