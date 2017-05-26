/****************************************************************
*								*
*	Copyright 2013 Fidelity Information Services, Inc	*
*								*
*	This source code contains the intellectual property	*
*	of its copyright holder(s), and is made available	*
*	under a license.  If you do not know the terms of	*
*	the license, please stop and do not read further.	*
*								*
****************************************************************/
package com.test.ji;

/**
 * A general-purpose container to indicate the name, type, and direction of an argument or return value.
 */
public class GTMType {
	public static final int INPUT_ONLY = 0, OUTPUT_ONLY = 1, INPUT_OUTPUT = 2;
	public static final int GTM_STATUS = -2, VOID = -1, GTM_BOOLEAN = 0, GTM_INTEGER = 1, GTM_LONG = 2, GTM_FLOAT = 3, GTM_DOUBLE = 4,
			GTM_STRING = 5, GTM_BYTE_ARRAY = 6, JAVA_STRING = 7, JAVA_BYTE_ARRAY = 8, JAVA_BIG_DECIMAL = 9;

	/**
	 * Directions.
	 */

	public static final int[] DIRECTIONS = new int[] {
		GTMType.INPUT_ONLY, GTMType.OUTPUT_ONLY, GTMType.INPUT_OUTPUT };
	public static final int DIRECTIONS_LENGTH = DIRECTIONS.length;

	/**
	 * Argument types.
	 */

	public static final int[] BASIC_ARG_TYPES = new int[] {
		GTMType.GTM_BOOLEAN, GTMType.GTM_INTEGER, GTMType.GTM_LONG,
		GTMType.GTM_FLOAT, GTMType.GTM_DOUBLE };
	public static final int BASIC_ARG_TYPES_LENGTH = BASIC_ARG_TYPES.length;

	public static final int[] COMPLEX_CALLIN_ARG_TYPES = new int[] {
		GTMType.GTM_STRING, GTMType.GTM_BYTE_ARRAY, GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY, GTMType.JAVA_BIG_DECIMAL };
	public static final int COMPLEX_CALLIN_ARG_TYPES_LENGTH = COMPLEX_CALLIN_ARG_TYPES.length;

	public static final int[] COMPLEX_CALLOUT_ARG_TYPES = new int[] {
		GTMType.GTM_STRING, GTMType.GTM_BYTE_ARRAY, GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY };
	public static final int COMPLEX_CALLOUT_ARG_TYPES_LENGTH = COMPLEX_CALLOUT_ARG_TYPES.length;

	public static final int[] ALL_CALLIN_ARG_TYPES = new int[] {
		GTMType.GTM_BOOLEAN, GTMType.GTM_INTEGER, GTMType.GTM_LONG, GTMType.GTM_FLOAT, GTMType.GTM_DOUBLE,
		GTMType.GTM_STRING, GTMType.GTM_BYTE_ARRAY, GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY, GTMType.JAVA_BIG_DECIMAL };
	public static final int ALL_CALLIN_ARG_TYPES_LENGTH = ALL_CALLIN_ARG_TYPES.length;

	public static final int[] ALL_CALLOUT_ARG_TYPES = new int[] {
		GTMType.GTM_BOOLEAN, GTMType.GTM_INTEGER, GTMType.GTM_LONG, GTMType.GTM_FLOAT, GTMType.GTM_DOUBLE,
		GTMType.GTM_STRING, GTMType.GTM_BYTE_ARRAY, GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY };
	public static final int ALL_CALLOUT_ARG_TYPES_LENGTH = ALL_CALLOUT_ARG_TYPES.length;

	/**
	 * Argument and argument type names.
	 */

	public static final String[] JAVA_ARG_NAMES = new String[] {
		"gtmBoolean", "gtmInteger", "gtmLong", "gtmFloat", "gtmDouble",
		"gtmString", "gtmByteArray", "javaString", "javaByteArray", "javaBigDecimal"};

	public static final String[] JAVA_ARG_TYPE_NAMES = new String[] {
		"GTMBoolean", "GTMInteger", "GTMLong", "GTMFloat", "GTMDouble",
		"GTMString", "GTMByteArray", "String", "byte[]", "BigDecimal"};

	public static final String[] TABLE_ARG_TYPES = new String[] {
		"gtm_jboolean_t", "gtm_jint_t", "gtm_jlong_t", "gtm_jfloat_t", "gtm_jdouble_t",
		"gtm_jstring_t", "gtm_jbyte_array_t", "gtm_jstring_t", "gtm_jbyte_array_t", "gtm_jbig_decimal_t"};

	/**
	 * Return types.
	 */

	public static final int[] BASIC_CALLIN_RET_TYPES = new int[] {
		GTMType.VOID, GTMType.GTM_BOOLEAN, GTMType.GTM_INTEGER,
		GTMType.GTM_LONG, GTMType.GTM_FLOAT, GTMType.GTM_DOUBLE };
	public static final int BASIC_CALLIN_RET_TYPES_LENGTH = BASIC_CALLIN_RET_TYPES.length;

	public static final int[] COMPLEX_CALLIN_RET_TYPES = new int[] {
		GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY };
	public static final int COMPLEX_CALLIN_RET_TYPES_LENGTH = COMPLEX_CALLIN_RET_TYPES.length;

	public static final int[] ALL_CALLIN_RET_TYPES = new int[] {
		GTMType.VOID, GTMType.GTM_BOOLEAN, GTMType.GTM_INTEGER,
		GTMType.GTM_LONG, GTMType.GTM_FLOAT, GTMType.GTM_DOUBLE,
		GTMType.JAVA_STRING, GTMType.JAVA_BYTE_ARRAY };
	public static final int ALL_CALLIN_RET_TYPES_LENGTH = ALL_CALLIN_RET_TYPES.length;

	public static final int[] ALL_CALLOUT_RET_TYPES = new int[] {
		GTMType.VOID, GTMType.GTM_STATUS, GTMType.GTM_LONG};
	public static final int ALL_CALLOUT_RET_TYPES_LENGTH = ALL_CALLOUT_RET_TYPES.length;

	/**
	 * Return type names.
	 */

	public static final String[] COMPLEX_CALLIN_RET_TYPE_WORDS = new String[] {
		"String", "ByteArray"};

	public static final String[] ALL_CALLIN_RET_TYPE_NAMES = new String[] {
		"void", "boolean", "int", "long", "float", "double", "String", "byte[]"};

	public static final String[] ALL_CALLIN_RET_TYPE_WORDS = new String[] {
		"Void", "Boolean", "Int", "Long", "Float", "Double", "String", "ByteArray"};

	public static final String[] ALL_CALLOUT_RET_TYPE_NAMES = new String[] {
		"void", "GTMInteger", "GTMLong"};

	public static final String[] ALL_CALLOUT_RET_TYPE_WORDS = new String[] {
		"void", "int", "long"};

	public static final String[] TABLE_RET_TYPES = new String[] {
		"gtm_status_t", "void", "gtm_jboolean_t", "gtm_jint_t", "gtm_jlong_t", "gtm_jfloat_t", "gtm_jdouble_t",
		"gtm_jstring_t", "gtm_jbyte_array_t", "gtm_jstring_t", "gtm_jbyte_array_t", "gtm_jbig_decimal_t"};

	String name;
	int direction, type;

	public GTMType(String name, int direction, int type) {
		this.name = name;
		this.direction = direction;
		this.type = type;
	}
}
