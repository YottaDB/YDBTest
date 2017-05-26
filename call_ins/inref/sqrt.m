sqroot(num,root)
       Use 0
       W !," M -->C -> M..."
       W !," M2, $ZLEVEL = ",$ZLEVEL
       New p 
       Set root=0
       Set num=$S(num<0:-num,num=0:1,1:num)   
       Set root=$S(num>1:num\1,1:1/num)
       Set root=$E(root,1,$L(root)+1\2) set:num'>1 root=1/root
       For p=1:1:6 Set root=num/root+root*.5
       Q 
