#include "gtm_string.h" 
#include "gtm_stdio.h"
#include "gtmxc_types.h"

int main()
{
	gtm_status_t status;
	char err[500];
	gtm_char_t* astr; 

	status = gtm_init();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	astr = (gtm_char_t*)gtm_malloc(32767);
	memset(astr,'A',32766);
	astr[32766] = '\0';
	status = gtm_ci("maxstr",astr);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	astr = (gtm_char_t *)gtm_malloc(65536);
	memset(astr,'A',65535);
	astr[65535] = '\0';
	status = gtm_ci("maxstr",astr);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	astr = (gtm_char_t *)gtm_malloc(1048576);
	memset(astr,'A',1048575);
	astr[1048575] = '\0';
	status = gtm_ci("maxstr",astr);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}

	astr = (gtm_char_t *)gtm_malloc(1048590);
	memset(astr,'A',1048589);
	astr[1048589] = '\0';
	PRINTF("The following call will give max_strlen error\n");
	status = gtm_ci("maxstr",astr);
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
	gtm_free(astr);

	status = gtm_exit();
	if(status)
	{
		gtm_zstatus(&err[0],500);
		PRINTF(" %s\n",err);
	}
}
