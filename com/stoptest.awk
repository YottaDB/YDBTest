{pid[NR] = $4;
 ppid[NR] = $5;
# print
 if (find_parent == "1")
          {
	  if (pid[NR] == thepid) {print ppid[NR];exit}
	  }
}
 
 END  { 
 # do not do END processing if simply looking for the parent
 if (find_parent == "1") exit; 

 for(i in pid) 
	  {
	  if (ppid[i] == thepid) list[no++]=pid[i] 
	  }

if (find_children!= "1")
	{ #then there must have been one process only
	 for(elem=0;elem<no;elem++)
	  print list[elem]
	  }
   else
   	{
	 for(elem=0;elem<no;elem++)
	   {#print "################\n" elem " " no " " list[elem] " " ;
	   #for (tmp in list) printf " " list[tmp]; printf "\n"
	   this_is_child=1;
	   for(i in pid) 
		{ 
	        if (ppid[i] == list[elem]) 
			{ list[no++]=pid[i]; 
			  this_is_child=0; 
			  #print ppid[i] " is not a child\n"
			}
		}
		if (this_is_child) 
		   { child[child_no++] = list[elem]; 
		     #print "found child" list[elem]
		    }
#	 for ( xx in child) printf child[x] " " ;printf "\n"
	    }


	 }

for (x in child) print  child[x]
 }

