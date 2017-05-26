munimaxstr(str,char);; 
     w "byte length of str: ",$zlength(str),!
     set mstr="" set $p(mstr,char,$length(str)+1)=""
     if mstr=str write "M got the correct string",!
     else  write "M got the wrong string",!
     use $P
     q
