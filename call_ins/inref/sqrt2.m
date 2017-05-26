sqroot(num,root)
     Use 0
     w !,"M1, C->M->C->M",!
     New p 
     Set root=0
     Set num=$S(num<0:-num,num=0:1,1:num)   
     Set root=$S(num>1:num\1,1:1/num)
     Set root=$E(root,1,$L(root)+1\2) set:num'>1 root=1/root
     For p=1:1:6 Set root=num/root+root*.5
     w !,"Using ",$text(+0)," the root of ",num," is ",root
     w !,"Now <Set square=$&squarec(root)> will do external call to C",!
     Set square=$&squarec(root)
     Use 0
     w !,"External call routine ",$text(+0)," returning to the square of ",num," as ",square,!
     Q 
