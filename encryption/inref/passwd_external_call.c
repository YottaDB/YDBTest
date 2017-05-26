#include <stdlib.h>

#define GTM_PASSWD "gtm_passwd"
#define GTM_PASSWD_MASKED "gtm_passwd_masked"
#define GTM_WRONG_PASSWD_MASKED "gtm_wrong_passwd_masked"
#define MAX	64

char	env_str[MAX];
int setCorrectPasswd()
{
	char	*ptr;
	ptr = (char *)getenv(GTM_PASSWD_MASKED);
	snprintf(env_str, MAX, "%s=%s", GTM_PASSWD, ptr);
	return putenv(env_str);
}

int setWrongPasswd()
{
	char 	*ptr;
	ptr = (char *)getenv(GTM_WRONG_PASSWD_MASKED);
	snprintf(env_str, MAX, "%s=%s", GTM_PASSWD, ptr);
	return putenv(env_str);
}

int setNullPasswd()
{
	snprintf(env_str, MAX, "%s=%s", GTM_PASSWD, "");
	return putenv(env_str);
}
