# called with the output of the at command, writes the time in the format for the directory creation
# called with -v remove=1 prints out the argument to remove the at command
BEGIN{ 	mons="jan feb mar apr may jun jul aug sep oct nov dec"
	split(mons,months," ")
	for (i=1;i<13;i++) month_no[months[i]]=i
	# the zero padding
	for (i=1;i<10;i++) month_no[months[i]]="0"month_no[months[i]]
}
{$0=tolower($0)
  if ($0 ~ /^job/) 
       { if (remove) {print $2;exit}
	gsub("will be run","");
	gsub("est","");
	gsub(/:/,"")
	if (NF == 5) 
		{date=$4"_"$5"00";}
	else
		{day = $6; if (day < 10) day = "0" day
		date=$8 month_no[$5] day "_" $7
		}
	gsub(/\./,"",date);
	gsub(/-|^../,"",date);
	print date
       }
}
