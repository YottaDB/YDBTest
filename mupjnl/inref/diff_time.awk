# use f$cvtime() to get the begin and finish time
# suppose the parameters are as follows:
# 1. begin date
# 2. begin time
# 3. finish date
# 4. finish time
# and all the parameters are in one input file
BEGIN{
split("12 31 24 60 60",max," ");
split("31 28 31 30 31 30 31 31 30 31 30 31",month," ");
split("86400 3600 60",content, " ");
#for (i in max) print i"#"max[i]
 }

{
gsub(/\./,":");
dateb=$1
timeb=$2
datef=$3
timef=$4
split(dateb,db,"-"); split(datef,df,"-");
split(timeb,tb,":"); split(timef,tf,":"); 
begin_string=db[2] " " db[3] " " tb[1] " " tb[2] " " tb[3]
final_string=df[2] " " df[3] " " tf[1] " " tf[2] " " tf[3]
split(begin_string,begin," ");
split(final_string,final," ");
mon = 0+db[2];
max[2] = month[mon];
}


END {
for (i=5;i>0;i--)
  {  
   result[i] = final[i]-begin[i];
   if (result[i]<0) 
     { result[i]+=max[i];
       final[i-1]--;
     }
       #printf i"  "final[i] ","begin[i] ":" result[i]
  }
if (result[2]!=0) final[1]=1 #no test is going to take more than 24 hours
# for (i=2;i<5;i++) printf result[i]":" ; printf result[5] 
sum = 0;
for (i=2;i<5;i++) sum+=result[i]*content[i-1]; sum+=result[5]; printf sum

     }
