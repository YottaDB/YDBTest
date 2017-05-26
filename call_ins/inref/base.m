base(n,y,z)
     w !,"In M1, C -> M -> M"
     New val Set val=""
     If (n<0)!(y<2)!(y>16)!(z<2)!(z>16)!(+n[".") Q val
     Set n=$$decimal^decimal(n,y)
     If z=10 Set val=n Q val
     For  Set i=n#z,n=n\z,val=$S(i>9:$E("ABCDEF",i-9),1:i_val) Q:'n
     Q val
