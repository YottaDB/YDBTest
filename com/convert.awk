BEGIN{
	fn="convert";
	genfile(fn);
	string="$$FUNC^%HD";
}
function genfile(filename)
{
	out=filename".m";
	print filename"  ;" > out;
	print "		; generated from convert.awk" > out;
	print "		if (0=$DATA(cnti)) set cnti=0" > out;
}
FILENAME ~ /special_casing.txt/ {
	i=j=1;
	if ( $0 ~ /^[ 	]*LOCALE_BEGIN/ )
	{
		fn=$2"convert";
		genfile(fn);
		convertarray[j]=fn;
		localearray[j]=$3;
		j++;
		next;
	}
	if ( $0 ~ /^[ 	]*LOCALE_END/ )
	{
		print "		do check^zconvert" > out
		print "		;end of "fn" program" > out
		print "		quit" > out
		next;
	}
	if ($0 ~ /^[ 	]*#/) next;	#skip comment lines
	gsub("; ",";",$0) # trim spaces
	split($0,str_array,";") # split fields to be set separately
	while ( i < 5 )
	{
		if ( "" == str_array[i] )
		{
			str[i]="\"\""
			i++;
			continue;
		}
		j=1
		split(str_array[i],tmparr," ") # split the field further if we have multiple byte representation for a char
		while ( "" != tmparr[j])
		{
			str[i]=str[i] string"(\""tmparr[j]"\")"
			if ( "" != tmparr[j+1] ) str[i]=str[i]","
			j++
		}
		str[i]="$CHAR("str[i]")"
		i++
	}
	if ( "" != str_array[6] ) str_array[5]=str_array[6]
	printf "		set cnti=cnti+1," > out
	printf "testarorg(cnti)="str[1]"," > out
	printf "testarl(cnti)="str[2]"," > out
	printf "testart(cnti)="str[3]"," > out
	printf "testaru(cnti)="str[4]"," > out
	printf "comments(cnti)=\""str_array[5]"\"" > out
	str[1]=str[2]=str[3]=str[4]=""
	print "" > out
}
END{
	# print the arrays gathered from special_casing.txt and set it to a variable
	# these will be used by any test routine that runs convert.m, for eg: unicode/inref/zconvert.m
	cnt=1
	out="convert.m"
	while ( "" != convertarray[cnt] )
	{
		print "		set convertarray("cnt")=\""convertarray[cnt]"\"" > out
		print "		set localearray("cnt")=\""localearray[cnt]"\"" > out
		cnt++;
	}
	print "		set arrcnt="cnt-1 > out
	print "		;end of program" > out
	print "		quit" > out
	system(ENVIRON[ "convert_to_gtm_chset" ] " " out) 
}
