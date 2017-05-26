decimal(x,y) 
      w !,"In M2, C -> M -> M"
      New val,i 
      Set val=0  If y=10 Set val=x GOTO extx
      For I=1:1:$L(x) Set val=val*y+($F("0123456789ABCDEF",$E(x,I))-2)
      ;
extx  Q val
