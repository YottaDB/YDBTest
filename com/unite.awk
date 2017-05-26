FILENAME !~/submitted_tests/ { 
  line[FILENAME,FNR]=$0
  tmp_fname[FILENAME]=FILENAME
  no_lines[FILENAME]=FNR
  #print FILENAME " # " $0 " # " FNR
 }
FILENAME ~/submitted_tests/ { 
  i=$2 "_" $1
  #print "."i","
  $1=""
  $2=""
  options_line[i]=$0
}

END{ 
     #if (debug) print "this is debug"
     exist_file="" #unnecessary, but as precaution
     #correct file names since they are in different directories and submitted_tests keeps options
     for (x in tmp_fname)
     { for (i in options_line)
	{ #the corresponding line of options in submitted_tests
	  #matchsting is necessary, if i is used, test_1 and test_11 are
	  #matched to be the same (so the order of the match determines who wins)
	  matchstring = i "([^0-9]|$)"
	  if (x ~ matchstring)
	     { fname[x]=i
	       fname_backup[x]=i
	       #print "x:" x "i:" i
	      }
	 }
     }

     for (i in fname) 
	{ exist_file=exist_file " " i
	  split(options_line[fname[i]],temp)
	  for (x in temp) 
	    {  universal[process(temp[x],"correct")]=1
	       current[process(temp[x],"correct")]=1
	      }
	  # {printf "UNIVERSAL_";for (x in universal) printf x":"; print }
          cur[i]=1 #the current line of this file to be printed 
	  no_files++
	  #counter to compare each file vs the others
	  for (j in fname) check[i,j]=1 
	  }

     total_files=no_files
	
	  #now start parsing
     while (no_files)
	{
	 #{printf "[" ;for (i in fname) printf  i":"cur[i]"," ;print "]"}
	 for (this in fname)
	   {
	    #print "THIS IS THIS" this
	    #for (x in fname) {printf "["cur[x]  "]"; print}
	    cur_line=line[this,cur[this]]
            not_printed=0;
	    here=0; nomatch=0
	    for (vs in fname)
	       { if (vs == this) continue
	         match_point[vs]=find_line(this,vs)
	         if (match_point[vs]==cur[vs]) here++	#;printf "match here" }
		 else if (match_point[vs]<cur[vs]) nomatch++ #;print "nomatch"}
		 #else  	printf "match at further"
		}
	    #-1 to eliminate file itself
	    #matches all files at current location, or does not match at all
	    #ie there aren't any files where it matches further
	    # OR does not match any file at any point, only in this file
	    if ((here==no_files-1-nomatch) || (nomatch==no_files-1))
	        { 
		  print_options();
		  #print "XXXXXXXXXXXX"
		  check_end();		  
		  break;
		 }
	        else not_printed++
		  #something is matching, but ahead,so print one of them 
		   

	   }
	   #print "\t\t\t\twrite one not_printed:no_files_(" not_printed ":"no_files")"
	   if ((not_printed)&&(no_files)) 
	    {#print the last one (or any other one)
	     #"this" needs special care since it has never been compared
	     match_point[this]=find_line(this,this);
	     print_options();
	     for (vs in fname) if (match_point[vs]==cur[vs]) cur[vs]++;
	     check_end();
             }
        }
#print the last chunk of "bad" text
#print "at the end"
print_next_chunk()
}

function find_line(this,vs)
{
     #find and return where line cur[this] matches in file vs
     #printf "("line[this,cur[this]]")"
     for (j=cur[vs];j<=no_lines[vs];j++)
       { #printf "vs " line[vs,j] " from " vs " at "j
	 if (line[this,cur[this]]==line[vs,j]) #match
	   { #print line[this,cur[this]] " MATCH "vs " (("line[vs,j] ")) at " j
	    return j
	    }
       }
       return -1 #NO MATCH
}

function check_end()
{
#Find out if all files have been printed out and remove those finished from fname[]
#total_files has to be used although the finished file is "deleted" from fname
#because the filename might be taken somewhere already (i.e. it might come up
#somewhere else although deleted here
#print "check end"
no_files=total_files
for (i in tmp_fname)
  { #i=fname[tmp_i] 
    #printf "XXXX"i"_" cur[i] "(out of" no_lines[i] ")";
    if (cur[i]>no_lines[i]) { #print "delete " i " " fname[i]
    				delete fname[i];
			     no_files--;
			    #print "one down"
			    }
   }
#print "no_files " no_files;
#for (i in fname) print i " " fname[i]
#if (no_files==0) print "FIN"
}

function print_next_chunk()
{
          if (result_dif!=0)
		{
	  	#if (debug) print "oooo"
		#if (debug) print "XXXXXXXXXXXXXXXXXXXX" result_dif
		#if (debug) 
		#print "number_of_times " number_of_times
		for (x=1;x<=number_of_times;x++)
			{#print "____________"x " "the_string[x]
			#if (debug) 
			#printf "______"
			print the_string[x]
			printf all_fil
			#print "xxxxxxxxxxxxxxxx:"
			}
		}
	result_dif=0
	#for (abc in fname) print abc " " fname[abc];

}

function print_options(write_this)
{
#determine all files the printed line is in, and print the options difference accordingly (by calling print_options_dif()
   exist_file_old=exist_file
   exist_file=""
   for (x in fname_backup)
     { #print "CHECK THIS LINE " x  " " line[x,cur[x]] " " cur_line
	if (x in fname) 
		if (line[x,cur[x]]==cur_line) 
			{
			exist_file=exist_file " " x
			write_this[fname_backup[x]]=1
			# if (debug)  print "#" x "#" options_line[fname[x]]
			}
		else
		{write_this[fname_backup[x]]=0 ; #print "dont print this line"
		  }
	else
	 {
	 write_this[fname_backup[x]]=0;
	 }
      }
#if (debug) for (nn in write_this) print "1###" nn" "write_this[nn]
   #if (debug) 
   #if (debug) print "[" exist_file_old "->" exist_file "]" 
   #since the ordering of filenames will always be the same, = can be used
   #print "NEW"exist_file 
   #print "OLD"exist_file_old
   if (exist_file!=exist_file_old) 
	{ 
	  print_next_chunk();
          result_dif = print_options_dif(write_this);
	  #print "ccc"

          if (result_dif!=0) 
               {all_fil= ""}
	  #if (debug) print "____"
	 }
   #print "CCC"
   if (result_dif!=0) {all_fil=all_fil   cur_line "\n";}
    else   printf("%s\n",cur_line) #"\t"exist_file 

   for (x in fname) if (line[x,cur[x]]==cur_line) cur[x]++
   #for (x in fname) print x " " cur[x]
}

function print_options_dif(write_this,old_options,new_options,valid_old,valid_new,deny,allow)
{
#exist_file vs exist_file_old hold the files the lines are in
#grab options from them, find same ones
#the parameters are just the local variables used inside the function
#if (debug) print "___OLD:" exist_file_old "__NEW:" exist_file
split(exist_file,new_options);
#if (debug) print "````````````````"
#if (debug) for (i in write_this) print  i " " write_this[i] " " fname_backup[i]
#if (debug) print "'''''''''''''''''"
#if (debug) for (i in options_line) print  i options_line[i]
#if (debug) print ",,,,,,,,,,,,,,,,,"
for (x in new_options) 
  { i=fname[new_options[x]]
    #print i
    split(options_line[i],temp)
    for (elem in temp) valid_new[process(temp[elem],"correct")]=1
    #for (elem in temp) valid_new[temp[elem]]=1
    }
#if (debug) printf "new\t"; for (i in valid_new) printf i ":"; print
split(exist_file_old,old_options);
for (x in old_options) 
 { #if (debug) printf "( x" x "," old_options[x];
   # {print;for (nd in fname) printf "files:" nd ","fname[nd];print }
   i=fname_backup[old_options[x]];
   #print "##" i "##"options_line[i] "##"
   split(options_line[i],temp)
   for (elem in temp) valid_old[process(temp[elem],"correct")]=1
   }
#printf "old\t"; for (i in valid_old) printf i "."; print
deny_string=""
allow_string=""
new_allow_string=""
return_string = ""
dif_univ=""
# print valid_old[1]
#old,new,and universal are used seperately (instead of simply new and universal)
#to make the output file simpler to understand (by eliminating some DENY/ALLOW's)
DENY=0;ALLOW=0;
for (i in new_allow) new_allow[i]=0;
#{ printf "#SUSPEND_OUTPUT ";for (x in deny) printf x " ";print}
#{ printf "#ALLOW_OUTPUT ";for (x in allow) printf x " ";print}
#for (x in valid_old) if (valid_new[x]!=1) {DENY=1;deny[x]=1;deny_string " "x}
#for (x in valid_new) if (valid_old[x]!=1) {ALLOW=1;allow[x]=1;allow_string " "x}
#for (x in universal) if (valid_new[x]!=1) {DENY=1;deny[x]=2;dif_univ=dif_univ " "x}

#if (DENY==1) { printf "##SUSPEND_OUTPUT ";for (x in deny) printf x " ";print}
#if (ALLOW==1) { printf "##ALLOW_OUTPUT ";for (x in allow) printf x " ";print}
#for (x in valid_new)  printf "(" x " " valid_new[x] ")"
#print
#if (debug) for (x in current)  printf "("x " " current[x]")"
#print

# check if the structure found works

return_value = check_if_all_files_covered(write_this,valid_new) 

#print ":::"return_value;
if (return_value == "BAD")
  { 
    #print "\t\t\t\t just print them out individually!:" cur_line
    #print "::::::::::"
    func_many_literals(write_this,current);
    return "good"; 
  }

# if it works

for (x in valid_new) if (current[x]!=1) 
			{allow_string= allow_string " "x
			 current[x]=1}
			 #else print x" is there"
for (x in current) if (current[x]==1) 
		     if (!(x in valid_new)) 
			{deny_string=deny_string " "x;
			 current[x]=0}
			#else print x "is still there"
#print "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
#for (n in options_line) print n options_line[n]
#for (abcd in fname) print "this is this" abcd fname[abcd]

if (deny_string!="") print "##SUSPEND_OUTPUT " deny_string
if (allow_string!="") print "##ALLOW_OUTPUT " allow_string
#for ( i in new_allow) print "new_allow" i ", " new_allow[i]
#for (x in valid_new) { if (new_allow[i]>0) new_allow_string= new_allow_string " " x
#                          else if (new_allow[i]!=-1000) return_string = return_string " "x }
#print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX:new_allow_string " new_allow_string, "return_string" return_string;
#for (x in universal) if (valid_new[x]!=1)
#if (dif_univ !="") if (no_files<total_files) print "SUSPEND_OUTPUT UNIV" dif_univ
return 0;
}
#####
#Currently, there is a case where this will fail
#i.e. print=a ANB b OR c AND d
# and deny= a AND c
#i.e. for complex option settings 
#the solution is to identify chunks of text and in cases like this, print that 
#chunk for all cases, which would be once for a AND b and once for c and d for 
#this example

function check_if_all_files_covered(write_this,valid_new,temp_cover,ok,not_ok)
{
#for ( x in fname_backup) print x " : " fname_backup[x]
#for (x in current) print "xXx " x " " current[x];
#for (x in valid_new) print "oOo " x " " valid_new[x];
#print "in check_if_all_files_covered"
for (x in write_this) 
{ 
	#print "xxxxxxxxxxxxxxxxxxxx" x " " write_this[x]; 

	#printf ",,,,"
	#for (n in valid_new) print n
	#print "::::::::::" x options_line[x]
	#print "1>>>>>>>>>>" x " "write_this[x] " " fname_backup[x]
	split(options_line[x],temp_cover)
	if (write_this[x]==1)
		{ # the file is to be written check that all options are in
		#print "to be written (" x
		ok[x]=0
		for (elem in temp_cover) 
		{#printf ">>>>>>>>>>>>>>" temp_cover[elem]
		#print "is it there?:"(elem in temp_cover); 
		if (temp_cover[elem] in valid_new) { ok[x]=1}}
		#print "ok:" ok[x]
		}
		else
		{ # the file is not to be written, check that at least one is out
		#print "not to be written (" x 
		#not_ok[x]=1
		ok[x]=0
		for (elem in temp_cover) 
		if (temp_cover[elem] in valid_new) {}#{print elem " " temp_cover[elem] } 
		 else {#{not_ok[x]=0; }
		 ok[x]=1;}
		#print "not_ok:" not_ok[x]
		}
}
TOUGH_LUCK=0
for (x in write_this)
{yep = -1
#printf "not_ok:" x " " not_ok[x] ; if (not_ok[x] == 1 ) yep=0 ; if (not_ok[x] == 0 ) yep=1#print "\t" 0; else print "" 
# print "\t\t\t\t yep:" yep;
# printf "    ok:" x " " ok[x]     ; if (ok[x] == 1 ) yep=1 ; if (ok[x] == 0) yep=0;#print "\t" ok[x]
# print ""
# print "\t\t\t\t yep:" yep;
 if (not_ok[x]) TOUGH_LUCK=1
 if (ok[x] == 0) TOUGH_LUCK=1
 }


if (TOUGH_LUCK == 0) return 1;
	else 
	 { #print "CHECK THIS CHUNK AND PRINT IT CORRECTLY"
	   return "BAD";
	  }



}
function func_many_literals(write_this,current,temp)
{
#print "\t\t\t\txXxXxXxX"
number_of_times=0;
#print "now here"

#for (fx in write_this)
# print fx " "write_this[fx] ",,,,,,,,,,,,,,,,,,,,,, "

#for (y in current) print "[ " y " " current[y] "]"

for (y in current) current_multi[y]=current[y]
for (fx in write_this)
{ #print fx " "write_this[fx] ",,,,,,,,,,,,,,,,,,,,,, "
#print "this is now " fx
if (write_this[fx]==1)
	{ #print "\t\t\t\t)))))"number_of_times;
	#the_string[++number_of_times]=fx
	# delete does not work properly, simply use a new array
	#for (i in valid_new) delete valid_new[i]
	#printf"xxx"; for ( i in temp) print i " "valid_new[i]
	allow_string=""
	deny_string=""
	#print "options:" options_line[fx]
	for (i in valid_new_multi) valid_new_multi[i]=0
	temp[NULL]=0
	#for (i in temp) print temp[i]
	for (i in temp) temp[i]=0
	#for (i in temp) print temp[i], " i,,,,,,,,,"
	split(options_line[fx], temp)
	#for ( i in temp) print "(" i")" temp[i] 
	for ( i in temp) if (temp[i]!=0) valid_new_multi[temp[i]]=1# the options of this file (fx)
	#for ( i in temp) print "iii:"i ":"temp[i]":"valid_new_multi[temp[i]] ":"
	#for (y in valid_new_multi) if (valid_new_multi[y]) printf "IIInew_multi:" y "," ;print ""
	#for ( i in valid_new_multi) print "valid_new_multi"i ":"valid_new_multi[i] ":"
	#for (y in current_multi) print "current_multi" y "," current_multi[y] "." 
	for (y in valid_new_multi) 
				{
				#print "MMMMMM " y " "valid_new_multi[y]
				if (valid_new_multi[y]==1)
				if (current_multi[y]!=1)
					{allow_string= allow_string " "y
					#print "I like it " y
					 current_multi[y]=1}
				}
	#for ( n in current_multi) print "NOt yetnew: " n " " current_multi[n]
	for (y in current_multi) if (current_multi[y]==1)
				{ #print y ">" current_multi[y] valid_new_multi[y]
				if (valid_new_multi[y] != 1)
				{deny_string=deny_string " "y; #printf "DENY"
				#if (debug) print " I hate it " y 
				#if (debug) print "deny_string: " deny_string
				current_multi[y]=0}
				}
	#if (debug) for ( n in current_multi) print "new: " n " " current_multi[n]
	#if (debug) for ( n in valid_new_multi) print "valid_new_multi: " n " " valid_new_multi[n]
	#if (debug) print " "
	number_of_times++;
	if (deny_string != "") the_string[number_of_times]="##SUSPEND_OUTPUT " deny_string 
	if (allow_string != "") the_string[number_of_times]=the_string[number_of_times] "\n##ALLOW_OUTPUT" allow_string #"................................."
#if (debug) print the_string[number_of_times]
#if (debug) print "That is one"
	}
}



for (y in current_multi) current[y]=current_multi[y]
#if (debug) for ( n in current) print "yetnew: " n " " current[n]
#print ">>>>>>>>>>>>>>>>>"


}
