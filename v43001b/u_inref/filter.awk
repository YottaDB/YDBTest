BEGIN	{reg["AREG"]=reg["BREG"]=reg["DEFAULT"]=1} 
/Transactions from/	{$3="XXXX"; $5="YYYY";} 
/Transactions up to/	{$4="XXXX"} 
/blocks saved./ 	{$1="X"} 
/STOP issued/ 		{$NF="XXXX"} 
{ 	for (r in reg) 
	{
		gsub(r"_[0-9]*__[0-9]\\.",r"_XXXX__N."); 
		gsub(r"_[0-9a-f]*_......",r"_YYYY_ZZZZZZ")
	}
}
{print}

