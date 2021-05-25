/****************************************************************
 *								*
 * Copyright (c) 2013, 2015 Fidelity National Information	*
 * Services, Inc. and/or its subsidiaries. All rights reserved.	*
 *								*
 * Copyright (c) 2017-2021 YottaDB LLC and/or its subsidiaries. *
 * All rights reserved.						*
 *								*
 *	This source code contains the intellectual property	*
 *	of its copyright holder(s), and is made available	*
 *	under a license.  If you do not know the terms of	*
 *	the license, please stop and do not read further.	*
 *								*
 ****************************************************************/
package com.test.ji;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;

/**
 * The class generating all GTMJI test cases. All tests roughly follow the same template for M
 * and Java files; for more details, please refer to the comments within the TestCase class.
 */
public class TestXC {
	private static final String packagePrefix = "com/test/";
	private static String destDir;

	public static final String incretrap =
		"\tset $etrap=\"do incretrap^incretrap\" " +
		"set incretrap(\"PRE\")=\"write \"\"%\"\"_$piece($zstatus,\"\"%\"\",2),!\" " +
		"set incretrap(\"NODISP\")=1 " +
		"new $estack\n";

	/*
	 * Test 1: Try all basic argument and return types.
	 */
	public static void getTest1() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.BASIC_ARG_TYPES_LENGTH * GTMType.ALL_CALLOUT_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.BASIC_ARG_TYPES_LENGTH; argIndex++) {
				for (int retIndex = 0; retIndex < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex++) {
					final String argValue;
					final String argInit;
					final String expValue;
					final int argType = GTMType.BASIC_ARG_TYPES[argIndex];

					switch (argType) {
					case GTMType.GTM_BOOLEAN:
						int booleanValue = TestCommon.rand.nextInt(2);
						argValue = booleanValue + "";
						argInit = "set x=" + argValue;
						if (direction == GTMType.INPUT_ONLY)
							expValue = booleanValue + "";
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = (1 - booleanValue) + "";
						else
							expValue = "1";
						break;
					case GTMType.GTM_INTEGER:
						int intValue = TestCommon.rand.nextInt();
						argValue = intValue + "";
						argInit = "set x=" + argValue;
						if (direction == GTMType.INPUT_ONLY)
							expValue = intValue + "";
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = (intValue / 10) + "";
						else
							expValue = "123";
						break;
					case GTMType.GTM_LONG:
						long longValue;
						while (Math.abs((longValue = TestCommon.rand.nextLong())) >= 1E18);
						argValue = longValue + "";
						argInit = "set x=" + argValue;
						if (direction == GTMType.INPUT_ONLY)
							expValue = longValue + "";
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = (longValue / 10) + "";
						else
							expValue = "123";
						break;
					case GTMType.GTM_FLOAT:
						argValue = TestCommon.F5.format(TestCommon.rand.nextFloat());
						argInit = "set x=" + argValue;
						if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = TestCommon.F6.format(Float.parseFloat(argValue) / 10);
						else
							expValue = "123";
						break;
					case GTMType.GTM_DOUBLE:
						double doubleValue = TestCommon.rand.nextDouble();
						if (doubleValue < TestCommon.M_MIN)
							doubleValue = 0;
						argValue = TestCommon.D14.format(doubleValue);
						argInit = "set x=" + argValue;
						if (direction == GTMType.INPUT_ONLY)
							expValue = argValue;
						else if (direction == GTMType.INPUT_OUTPUT)
							expValue = TestCommon.D15.format(Double.parseDouble(argValue) / 10);
						else
							expValue = "123";
						break;
					default:
						argInit = null;
						argValue = null;
						expValue = null;
					}

					final String retValue;
					int retType = GTMType.ALL_CALLOUT_RET_TYPES[retIndex];

					switch (retType) {
					case GTMType.VOID:
						retValue = "";
						break;
					case GTMType.GTM_STATUS:
						retValue = TestCommon.rand.nextInt() + "";
						break;
					case GTMType.GTM_LONG:
						long value;
						while (Math.abs((value = TestCommon.rand.nextLong())) >= 1E18);
						retValue = value + "";
						break;
					default:
						retValue = null;
					}

					testCases[testCasesIndex++] = new TestCase("Test1", TestCase.CALL_OUT, retType,
							new GTMType(M.genVarName(false), direction, argType)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							mCode.append("\tnew $ztrap set $etrap=\"if '($ecode[\"\"150376730\"\") do incretrap^incretrap\" " +
									"set incretrap(\"PRE\")=\"write \"\"%\"\"_$piece($zstatus,\"\"%\"\",2),!\" " +
									"set incretrap(\"NODISP\")=1 " +
									"new $estack\n");
							mCode.append("\t" + argInit + "\n");
							if (ret == GTMType.VOID)
								mCode.append("\tdo &test1." + name + "(");
							else
								mCode.append("\tset r=$&test1." + name + "(");
							mCode.append("\"com/test/Test1\",\"" + name + "\",");
							if (direction != GTMType.INPUT_ONLY)
								mCode.append(".");
							mCode.append("x)\n");
							if (ret != GTMType.VOID && (ret != GTMType.GTM_STATUS || retValue.equals("0")))
								mCode.append("\twrite \"Job returned \"_r,!");
							mCode.append("\twrite \"The argument upon return is \"_x,!\n");
							mCode.append("\tquit\n");
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							String argName;
							switch (argType) {
							case GTMType.GTM_BOOLEAN:
								argName = "gtmBoolean";
								break;
							case GTMType.GTM_INTEGER:
								argName = "gtmInteger";
								break;
							case GTMType.GTM_LONG:
								argName = "gtmLong";
								break;
							case GTMType.GTM_FLOAT:
								argName = "gtmFloat";
								break;
							case GTMType.GTM_DOUBLE:
								argName = "gtmDouble";
								break;
							default:
								argName = null;
							}
							if (direction != GTMType.OUTPUT_ONLY) {
								if (argType == GTMType.GTM_FLOAT)
									builder.append("\t\tSystem.out.println(floatFormat.format(" + argName + ".value));\n");
								else if (argType == GTMType.GTM_DOUBLE)
									builder.append("\t\tSystem.out.println(doubleFormat.format(" + argName + ".value));\n");
								else
									builder.append("\t\tSystem.out.println(" + argName + ");\n");

								if (argType != GTMType.GTM_BOOLEAN)
									builder.append("\t\t" + argName + ".value /= 10;\n");
								else
									builder.append("\t\t" + argName + ".value = !" + argName + ".value;\n");
							} else {
								if (argType != GTMType.GTM_BOOLEAN)
									builder.append("\t\t" + argName + ".value = 123;\n");
								else
									builder.append("\t\t" + argName + ".value = true;\n");
							}
							if (ret != GTMType.VOID)
								builder.append("\t\treturn " + retValue + (ret == GTMType.GTM_LONG ? "L" : "") + ";\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getMResponse() {
							StringBuilder builder = new StringBuilder();
							if (ret != GTMType.VOID) {
								if (ret == GTMType.GTM_STATUS && !retValue.equals("0"))
									builder.append("%YDB-E-ZCSTATUSRET, External call returned error status\n");
								else
									builder.append("Job returned " + retValue + "\n");
							}
							builder.append("The argument upon return is " + expValue + "\n");
							return builder.toString();
						}

						@Override
						public String getJavaResponse() {
							if (direction != GTMType.OUTPUT_ONLY) {
								if (argType == GTMType.GTM_BOOLEAN) {
									if (argValue.equals("0"))
										return "false\n";
									else
										return "true\n";
								}
								return argValue + "\n";
							} else
								return "";
						}
					};
				}
			}
		}

		writeTestCase(testCases, 1);
	}

	/*
	 * Test 2: Try the more complex argument and return types.
	 */
	public static void getTest2() throws Exception {
		TestCase[] testCases = new TestCase[(GTMType.COMPLEX_CALLOUT_ARG_TYPES_LENGTH / 2) * GTMType.ALL_CALLOUT_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.COMPLEX_CALLOUT_ARG_TYPES_LENGTH; argIndex++) {
				for (int retIndex = 0; retIndex < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex++) {
					final String argValue;
					final String argInit;
					final String expValue;
					final int argType = GTMType.COMPLEX_CALLOUT_ARG_TYPES[argIndex];

					if (direction == GTMType.INPUT_ONLY)
					{
						// GTMString and GTMByteArray are only used for input-output and output-only directions;
						// the native String and byte[] are used otherwise
						if (argType == GTMType.GTM_STRING || argType == GTMType.GTM_BYTE_ARRAY)
							continue;
					} else {
						// for same reason as above, only use native String and byte[] for input-only direction
						if (argType == GTMType.JAVA_STRING || argType == GTMType.JAVA_BYTE_ARRAY)
							continue;
					}

					argValue = TestCommon.STRING_ARGS[TestCommon.rand.nextInt(TestCommon.STRING_ARGS_LENGTH)];
					switch (argType) {
					case GTMType.GTM_STRING:
						argInit = "set x=\"" + argValue + "\"";
						if (direction == GTMType.OUTPUT_ONLY)
							// 'ivan' (spelled in cyrillic) encoded in UTF-8
							expValue = new String(new byte[]{(byte)208, (byte)184, (byte)208, (byte)178,
									(byte)208, (byte)176, (byte)208, (byte)189});
						else
							expValue = argValue.substring(argValue.length() / 2);
						break;
					case GTMType.JAVA_STRING:
						argInit = "set x=\"" + argValue + "\"";
						expValue = argValue;
						break;
					case GTMType.GTM_BYTE_ARRAY:
						if (argValue.length() != 0) {
							byte[] bytes = argValue.getBytes("UTF-8");
							int length = bytes.length;
							StringBuilder builder = new StringBuilder("");
							for (int b = 0; b < length; b++) {
								if (b != 0)
									builder.append("_");
								builder.append("$zchar(");
								// normalizing the value to [0..255] range because bytes over 127 converted to
								// integers are negative
								builder.append((256 + bytes[b]) % 256);
								builder.append(")");
							}
							argInit = "set x=" + builder.toString();
						} else {
							argInit = "set x=\"\"";
						}
						if (direction == GTMType.OUTPUT_ONLY) {
							// 'ivan' (spelled in cyrillic) encoded in UTF-8
							byte[] outputArray = new byte[]{(byte)208, (byte)184, (byte)208, (byte)178,
									(byte)208, (byte)176, (byte)208, (byte)189};
							expValue = new String(outputArray, "UTF-8");
						} else {
							String secondHalf = argValue.substring(argValue.length() / 2);
							expValue = secondHalf + secondHalf;
						}
						break;
					case GTMType.JAVA_BYTE_ARRAY:
						if (argValue.length() != 0) {
							byte[] bytes = argValue.getBytes("UTF-8");
							int length = bytes.length;
							StringBuilder builder = new StringBuilder("");
							for (int b = 0; b < length; b++) {
								if (b != 0)
									builder.append("_");
								builder.append("$zchar(");
								builder.append((256 + bytes[b]) % 256);
								builder.append(")");
							}
							argInit = "set x=" + builder.toString();
						} else {
							argInit = "set x=\"\"";
						}
						expValue = argValue;
						break;
					default:
						argInit = null;
						expValue = null;
					}

					final String retValue;
					int retType = GTMType.ALL_CALLOUT_RET_TYPES[retIndex];

					switch (retType) {
					case GTMType.VOID:
						retValue = "";
						break;
					case GTMType.GTM_STATUS:
						retValue = TestCommon.rand.nextInt() + "";
						break;
					case GTMType.GTM_LONG:
						long value;
						while (Math.abs((value = TestCommon.rand.nextLong())) >= 1E18);
						retValue = value + "";
						break;
					default:
						retValue = null;
					}

					testCases[testCasesIndex++] = new TestCase("Test2", TestCase.CALL_OUT, retType,
							new GTMType(M.genVarName(false), direction, argType)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							mCode.append(incretrap);
							mCode.append("\t" + argInit + "\n");
							if (ret == GTMType.VOID)
								mCode.append("\tdo &test2." + name + "(");
							else
								mCode.append("\tset r=$&test2." + name + "(");
							mCode.append("\"com/test/Test2\",\"" + name + "\",");
							if (direction != GTMType.INPUT_ONLY)
								mCode.append(".");
							mCode.append("x)\n");
							if (ret != GTMType.VOID && (ret != GTMType.GTM_STATUS || retValue.equals("0")))
								mCode.append("\twrite \"Job returned \"_r,!");
							mCode.append("\twrite \"The argument upon return is \"_x,!\n");
							mCode.append("\tquit\n");
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							builder.append("\t\ttry {\n");
							String argName;

							switch (argType) {
							case GTMType.GTM_STRING:
								argName = "gtmString";
								if (direction == GTMType.OUTPUT_ONLY)
									builder.append("\t\t\tgtmString.value = new String(new byte[]{(byte)208, (byte)184, (byte)208, (byte)178, (byte)208, (byte)176, (byte)208, (byte)189});\n");
								else {
									builder.append("\t\t\tSystem.out.println(" + argName + ");\n");
									builder.append("\t\t\tgtmString.value = gtmString.value.substring(gtmString.value.length() / 2);\n");
								}
								break;
							case GTMType.GTM_BYTE_ARRAY:
								argName = "gtmByteArray";
								if (direction == GTMType.OUTPUT_ONLY)
									builder.append("\t\t\tgtmByteArray.value = new byte[]{(byte)208, (byte)184, (byte)208, (byte)178, (byte)208, (byte)176, (byte)208, (byte)189};\n");
								else {
									builder.append("\t\t\tSystem.out.println(" + argName + ");\n");
									builder.append("\t\t\tint length = gtmByteArray.value.length;\n");
									builder.append("\t\t\tbyte[] twoHalfs = new byte[length];\n");
									builder.append("\t\t\tSystem.arraycopy(gtmByteArray.value, length / 2, twoHalfs, 0, length / 2);\n");
									builder.append("\t\t\tSystem.arraycopy(gtmByteArray.value, length / 2, twoHalfs, length / 2, length / 2);\n");
									builder.append("\t\t\tgtmByteArray.value = twoHalfs;\n");
								}
								break;
							case GTMType.JAVA_STRING:
								argName = "javaString";
								builder.append("\t\t\tSystem.out.println(" + argName + ");\n");
								break;
							case GTMType.JAVA_BYTE_ARRAY:
								argName = "javaByteArray";
								builder.append("\t\t\tSystem.out.println(new String(" + argName + ", \"UTF-8\"));\n");
								break;
							}

							builder.append("\t\t} catch (Exception e) {\n");
							builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
							builder.append("\t\t}\n");
							if (ret != GTMType.VOID)
								builder.append("\t\treturn " + retValue + (ret == GTMType.GTM_LONG ? "L" : "") + ";\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getMResponse() {
							StringBuilder builder = new StringBuilder();
							if (ret != GTMType.VOID) {
								if (ret == GTMType.GTM_STATUS && !retValue.equals("0"))
									builder.append("%YDB-E-ZCSTATUSRET, External call returned error status\n");
								else
									builder.append("Job returned " + retValue + "\n");
							}
							builder.append("The argument upon return is " + expValue + "\n");
							return builder.toString();
						}

						@Override
						public String getJavaResponse() {
							if (direction != GTMType.OUTPUT_ONLY)
								return argValue + "\n";
							else
								return "";
						}
					};
				}
			}
		}

		writeTestCase(testCases, 2);
	}

	/*
	 * Test 3: Generate different kinds of errors in Java code.
	 */
	public static void getTest3() throws Exception {
		final String[] errorCodes = new String[]{
				"\t\tObject x = Integer.valueOf(0);\n\t\tSystem.out.println((String)x);\n",
				"\t\tSystem.out.println(new char[]{'a', 'b'}[3]);\n",
				"\t\tSystem.out.println(1 / 0);\n"};
		int numOfErrorCases = errorCodes.length;
		TestCase[] testCases = new TestCase[numOfErrorCases];
		String javaVersion = System.getProperty("java.version");
		/* Starting Java 11.* (e.g. 11.0.3) we have found the error string to be more descriptive
		 * so allow for that below. So we split the version string into 2 parts with "." as delimiter.
		 * The first part is the major version we are looking for. As long as it is < 11, we use the older
		 * error message. Otherwise we use the newer error message format.
		 */
		int	intver = Integer.parseInt(javaVersion.split("\\.")[0]);
		/* Additionally, on an ARMV6L system, we had Java 11.* installed but still saw the error string to
		 * not show up as descriptive as it does on x86_64 and AARCH64 systems that have Java 11.* installed.
		 * The current suspicion is that it is because the "java.vm.name" is different.
		 * On x86_64 and AARCH64, it is "OpenJDK 64-Bit Server VM" whereas on ARMV6L it is "OpenJDK Zero VM".
		 * Therefore we check that too before deciding whether to use the older or newer error message format.
		 */
		String javaVmName = System.getProperty("java.vm.name");
		String[] errorTexts = new String[3];
		errorTexts[0] = (intver >= 11)
					? "java.lang.ClassCastException: class java.lang.Integer cannot be cast to class java.lang.String (java.lang.Integer and java.lang.String are in module java.base of loader 'bootstrap')"
					: "java.lang.ClassCastException: java.lang.Integer cannot be cast to java.lang.String";
		errorTexts[1] = ((intver >= 11) && !javaVmName.equals("OpenJDK Zero VM"))
					?  "java.lang.ArrayIndexOutOfBoundsException: Index 3 out of bounds for length 2"
					: "java.lang.ArrayIndexOutOfBoundsException: 3";
		errorTexts[2] = "java.lang.ArithmeticException: / by zero";

		for (int errorCase = 0; errorCase < numOfErrorCases; errorCase++) {
			final int errorIndex = errorCase;

			testCases[errorIndex] = new TestCase("Test3", TestCase.CALL_OUT, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(incretrap);
					mCode.append("\tdo &test3." + name + "(\"com/test/Test3\",\"" + name + "\")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append(errorCodes[errorIndex]);
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return "%YDB-E-JNI, " + errorTexts[errorIndex] + "\n";
				}
			};
		}

		writeTestCase(testCases, 3);
	}

	/*
	 * Test 4: Ensure that null values are received in Java when trailing M arguments are skipped.
	 */
	public static void getTest4() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH * GTMType.ALL_CALLOUT_RET_TYPES_LENGTH * GTMType.DIRECTIONS_LENGTH];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			for (int argIndex = 0; argIndex < GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH; argIndex++) {
				final int argType = GTMType.ALL_CALLOUT_ARG_TYPES[argIndex];

				for (int retIndex = 0; retIndex < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex++) {
					final int retType = GTMType.ALL_CALLOUT_RET_TYPES[retIndex];

					testCases[testCasesIndex++] = new TestCase("Test4", TestCase.CALL_OUT, retType,
							new GTMType(M.genVarName(false), direction, argType)) {
						@Override
						public String getMCode() {
							StringBuilder mCode = new StringBuilder();
							mCode.append(mHeader);
							if (ret == GTMType.VOID)
								mCode.append("\tdo &test4." + name + "(");
							else
								mCode.append("\tif $&test4." + name + "(");
							mCode.append("\"com/test/Test4\",\"" + name + "\")\n");
							mCode.append("\tquit\n\n");
							return mCode.toString();
						}

						@Override
						public String getJavaCode() {
							StringBuilder builder = new StringBuilder();
							builder.append(javaHeader);
							builder.append("\t\tSystem.out.println(" + args[0].name + ");\n");
							if (retType != GTMType.VOID)
								builder.append("\t\treturn 0;\n");
							else
								builder.append("\t\treturn;\n");
							builder.append("\t}\n");
							return builder.toString();
						}

						@Override
						public String getJavaResponse() {
							return	"null\n";
						}
					};
				}
			}
		}

		writeTestCase(testCases, 4);
	}

	/*
	 * Test 5: Ensure appropriate errors on return type mismatch between what is specified in the call-out table
	 * and actually passed to the routine.
	 */
	public static void getTest5() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLOUT_RET_TYPES_LENGTH * GTMType.ALL_CALLOUT_RET_TYPES_LENGTH];
		int testCasesIndex = 0;

		for (int retIndex1 = 0; retIndex1 < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex1++) {
			final int retType1 = GTMType.ALL_CALLOUT_RET_TYPES[retIndex1];
			final String retTypeWord = GTMType.ALL_CALLOUT_RET_TYPE_WORDS[retIndex1];

			for (int retIndex2 = 0; retIndex2 < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex2++) {
				final int retType2 = GTMType.ALL_CALLOUT_RET_TYPES[retIndex2];
				final String fakeRetTypeWord = GTMType.ALL_CALLOUT_RET_TYPE_WORDS[retIndex2];

				testCases[testCasesIndex++] = new TestCase("Test5", TestCase.CALL_OUT, retType1) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append(incretrap);
						if (ret == GTMType.VOID)
							mCode.append("\tdo &test5." + name + "(");
						else
							mCode.append("\tif $&test5." + name + "(");
						mCode.append("\"com/test/Test5\",\"" + name + "\")\n");
						mCode.append("\tquit\n\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append("\tpublic static " + fakeRetTypeWord + " " + name + "(Object[] args) {\n");
						if (retType2 != GTMType.VOID)
							builder.append("\t\treturn 0;\n");
						else
							builder.append("\t\treturn;\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getJavaResponse() {
						if (retType1 != retType2)
							return	"%YDB-E-JNI, Method (" + retTypeWord + ")" + packagePrefix + testName + "." + name + " not found.\n";
						return "";
					}
				};
			}
		}

		writeTestCase(testCases, 5);
	}

	/*
	 * Test 6: Ensure appropriate errors when output-only or input-output arguments get replaced by containers of
	 * different type before being returned from Java.
	 */
	public static void getTest6() throws Exception {
		TestCase[] testCases = new TestCase[(GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH - 2) * 2];
		int testCasesIndex = 0;

		for (int dirIndex = 0; dirIndex < GTMType.DIRECTIONS_LENGTH; dirIndex++) {
			final int direction = GTMType.DIRECTIONS[dirIndex];

			if (direction == GTMType.INPUT_ONLY)
				continue;

			for (int argIndex = 0; argIndex < GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH; argIndex++) {
				final int argType = GTMType.ALL_CALLOUT_ARG_TYPES[argIndex];

				if (argType == GTMType.JAVA_BYTE_ARRAY || argType == GTMType.JAVA_STRING)
					continue;

				final String argInit;
				final String argTypeName = GTMType.JAVA_ARG_TYPE_NAMES[argIndex];

				switch (argType) {
				case GTMType.GTM_BOOLEAN:
				case GTMType.GTM_INTEGER:
				case GTMType.GTM_LONG:
				case GTMType.GTM_FLOAT:
				case GTMType.GTM_DOUBLE:
					argInit = "set x=123";
					break;
				case GTMType.GTM_STRING:
					argInit = "set x=\"123\"";
					break;
				case GTMType.GTM_BYTE_ARRAY:
					argInit = "set x=$zchar(49)_$zchar(50)_$zchar(51)";
					break;
				default:
					argInit = null;
				}

				testCases[testCasesIndex++] = new TestCase("Test6", TestCase.CALL_OUT, GTMType.VOID,
						new GTMType(M.genVarName(false), direction, argType)) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append(incretrap);
						mCode.append("\t" + argInit + "\n");
						mCode.append("\tdo &test6." + name + "(\"com/test/Test6\",\"" + name + "\",.x)\n");
						mCode.append("\tquit\n\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append(javaHeader);
						builder.append("\t\targs[0] = 321;\n");
						builder.append("\t\treturn;\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getMResponse() {
						return	"%YDB-E-JNI, Arg #1 to method " + packagePrefix + testName + "." + name +
							" is expected to be of type " + argTypeName + ", but different type found.\n";
					}
				};
			}
		}

		writeTestCase(testCases, 6);
	}

	/*
	 * Test 7: Do a System.exit() and ensure that the process terminates.
	 */
	public static void getTest7() throws Exception {
		TestCase[] testCases = new TestCase[] {
			new TestCase("Test7", TestCase.CALL_OUT, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tdo &test7." + name + "(\"com/test/Test7\",\"" + name + "\")\n");
					mCode.append("\twrite \"Process did not terminate!\"\n\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\tSystem.exit(0);\n");
					builder.append("\t}\n");
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 7);
	}

	/*
	 * Test 8: Do a MUPIP STOP on the MUMPS process and ensure that it fully terminates without cores.
	 * In this test GT.M calls out to Java, which then calls into GT.M.
	 */
	public static void getTest8() throws Exception {
		final String childControl = M.genVarName(true);
		final String ready = M.genVarName(true);

		try {
			new File(new File(destDir + "test8.ci").getParent()).mkdirs();
			BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(destDir + "test8.ci"),"UTF-8"));
			writer.write("setReady:\tvoid setReady^test8(I:gtm_jstring_t)\n");
			writer.close();
		} catch (IOException e) {
			e.printStackTrace();
		}

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test8", TestCase.CALL_OUT, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tif ($data(" + childControl + ")) do\n");
					mCode.append("\t.\twrite \"This is a child process!\",!\n");
					mCode.append("\t.\tdo &test8." + name + "(\"com/test/Test8\",\"" + name + "\")\n");
					mCode.append("\t.\twrite \"Java function called!\"\n");
					mCode.append("\t.\tfor i=1:1  hang 1  quit:i=60\n");
					mCode.append("\t.\thalt\n");
					mCode.append("\tset " + childControl + "=1\n");
					mCode.append("\twrite \"This is a parent process!\",!\n");
					mCode.append("\tset " + ready + "=0\n");
					mCode.append("\tjob ^test8\n");
					mCode.append("\twrite \"Started the child job!\",!\n");
					mCode.append("\tfor j=1:1  quit:(" + ready + "!(j=60))  hang 1\n");
					mCode.append("\tif $zsigproc($zjob,15)\n");
					mCode.append("\twrite \"Sent kill -15!\",!\n");
					mCode.append("\tfor j=1:1  quit:($zsigproc($zjob,0)!(j=30))  hang 1\n");
					mCode.append("\tif j'=30 write \"The child process is dead!\",!\n");
					mCode.append("\telse  write \"The child process (pid=\"_$zjob_\") is still alive!\",!\n");
					mCode.append("\tkill " + childControl + "\n");
					mCode.append("\tquit\n\n");
					mCode.append("setReady(ready)\n");
					mCode.append("\tset @ready=1\n");
					mCode.append("\tquit\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tGTMCI.doVoidJob(\"setReady\", \"" + ready + "\");\n");
					builder.append("\t\t\tSystem.out.println(\"The M job has terminated!\");\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return 	"This is a parent process!\n" +
							"Started the child job!\n" +
							"Sent kill -15!\n" +
							"The child process is dead!\n";
				};
			}
		};

		writeTestCase(testCases, 8);
	}

	/*
	 * Test 9: Verify that an error is issued on an incorrect package, label, Java class, or Java method name.
	 */
	public static void getTest9() throws Exception {
		final String[] mCodes = new String[]{
			"\tdo &test123.lbl0(\"com/test/Test9\",\"lbl0\")\n",
			"\tdo &test9.lbl123(\"com/test/Test9\",\"lbl1\")\n",
			"\tdo &test9.lbl2(\"com/test/Test123\",\"lbl2\")\n",
			"\tdo &test9.lbl3(\"com/test/Test9\",\"lbl123\")\n" };
		final String[] mResponses = new String[]{
			"%YDB-E-ZCCTENV, Environmental variable for external package ydb_xc_test123/GTMXC_test123 not set\n",
			"%YDB-E-ZCRTENOTF, External call routine lbl123 not found\n",
			"%YDB-E-JNI, Class com/test/Test123 is not found.\n",
			"%YDB-E-JNI, Method (void)" + packagePrefix + "Test9.lbl123 not found.\n" };

		int numOfCases = mCodes.length;

		TestCase[] testCases = new TestCase[numOfCases];

		for (int codeCase = 0; codeCase < numOfCases; codeCase++) {
			final int codeIndex = codeCase;

			testCases[codeIndex] = new TestCase("Test9", TestCase.CALL_OUT, GTMType.VOID) {
				@Override
				public String getMCode() {
					return 	mHeader +
						incretrap +
						mCodes[codeIndex] +
						"\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\tSystem.out.println(\"Method invoked!\");\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return mResponses[codeIndex];
				}
			};
		}

		writeTestCase(testCases, 9);
	}

	/*
	 * Test 10: Verify that an error is issued if more than 29 arguments are passed, the reason being
	 * that callg() interface can only deal with 32 arguments, and 3 of them are designated as Java class,
	 * Java method, and type description array.
	 */
	public static void getTest10() throws Exception {
		int numOfCases = 33;

		GTMType[] args = new GTMType[numOfCases];
		String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfCases; i++)
			args[i] = new GTMType(varNameBase + i, GTMType.INPUT_ONLY, GTMType.GTM_BOOLEAN);

		TestCase[] testCases = new TestCase[numOfCases];

		for (int testCase = 0; testCase < numOfCases; testCase++) {
			final int numOfTestArgs = testCase + 1;

			GTMType[] testArgs = new GTMType[numOfTestArgs];
			System.arraycopy(args, 0, testArgs, 0, numOfTestArgs);

			testCases[testCase] = new TestCase("Test10", TestCase.CALL_OUT, GTMType.GTM_LONG, testArgs) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(incretrap);
					for (int i = 0; i < numOfTestArgs; i++)
						mCode.append("\tset a" + i + "=1\n");
					mCode.append("\tif $&test10." + name + "(\"com/test/Test10\",\"" + name + "\"");
					for (int i = 0; i < numOfTestArgs; i++)
						mCode.append(",.a" + i);
					mCode.append(")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("\tpublic static long " + name + "(Object[] args) {\n");
					builder.append("\t\treturn 0;");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					if (numOfTestArgs > 30)
						return "%YDB-E-MAXACTARG, Maximum number of actual arguments exceeded\n";
					else if (numOfTestArgs > 29)
						return "%YDB-E-ZCMAXPARAM, Exceeded maximum number of external call parameters\n";
					else
						return "";
				}
			};
		};

		writeTestCase(testCases, 10);
	}

	/*
	 * Test 11: Expect an error when passing more actuals than formals.
	 */
	public static void getTest11() throws Exception {
		final int numOfFormals = 1 + TestCommon.rand.nextInt(28);
		final int numOfActuals = numOfFormals + 1;

		final GTMType[] formals = new GTMType[numOfFormals];

		String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfFormals; i++)
			formals[i] = new GTMType(varNameBase + i, GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)], GTMType.GTM_INTEGER);

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test11", TestCase.CALL_OUT, GTMType.VOID, formals) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					for (int i = 0; i < numOfActuals; i++)
						mCode.append("\tset a" + i + "=1\n");
					mCode.append("\tif $&test11." + name + "(\"com/test/Test11\",\"" + name + "\"");
					for (int i = 0; i < numOfActuals; i++) {
						mCode.append(",");
						if (i < numOfFormals && formals[i].direction != GTMType.INPUT_ONLY)
							mCode.append(".");
						mCode.append("a" + i);
					}
					mCode.append(")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("\tpublic static void " + name + "(Object[] args) {\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return	"%YDB-E-ZCARGMSMTCH, External call: Actual argument count, " + numOfActuals +
							", is greater than formal argument count, " + numOfFormals + "\n" +
							"\n" +
							"YDB>\n";
				}
			}
		};

		writeTestCase(testCases, 11);
	}

	/*
	 * Test 12: Expect to receive a null value in Java when the respective (trailing) argument from M is missing.
	 */
	public static void getTest12() throws Exception {
		final int numOfFormals = 1 + TestCommon.rand.nextInt(29);
		final int numOfActuals = numOfFormals - 1;

		final GTMType[] formals = new GTMType[numOfFormals];

		final String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfFormals; i++)
			formals[i] = new GTMType(varNameBase + i, GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)], GTMType.GTM_LONG);

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test12", TestCase.CALL_OUT, GTMType.VOID, formals) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					for (int i = 0; i < numOfActuals; i++)
						mCode.append("\tset a" + i + "=1\n");
					mCode.append("\tdo &test12." + name + "(\"com/test/Test12\",\"" + name + "\"");
					for (int i = 0; i < numOfActuals; i++) {
						mCode.append(",");
						if (i < numOfFormals && formals[i].direction != GTMType.INPUT_ONLY)
							mCode.append(".");
						mCode.append("a" + i);
					}
					mCode.append(")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("\tpublic static void " + name + "(Object[] args) {\n");
					builder.append("\t\ttry {\n");
					builder.append("\t\t\tSystem.out.println((GTMLong)args[" + (numOfFormals - 1) + "]);\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "null\n";
				}
			}
		};

		writeTestCase(testCases, 12);
	}

	/*
	 * Test 13: Ensure appropriate errors on invoking void functions in non-void fashion, or vice versa, from M.
	 */
	public static void getTest13() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLOUT_RET_TYPES_LENGTH * GTMType.ALL_CALLOUT_RET_TYPES_LENGTH];
		int testCasesIndex = 0;

		for (int retIndex1 = 0; retIndex1 < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex1++) {
			final int retType1 = GTMType.ALL_CALLOUT_RET_TYPES[retIndex1];
			final String retTypeWord = GTMType.ALL_CALLOUT_RET_TYPE_WORDS[retIndex1];

			for (int retIndex2 = 0; retIndex2 < GTMType.ALL_CALLOUT_RET_TYPES_LENGTH; retIndex2++) {
				final int retType2 = GTMType.ALL_CALLOUT_RET_TYPES[retIndex2];

				testCases[testCasesIndex++] = new TestCase("Test13", TestCase.CALL_OUT, retType1) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append(incretrap);
						if (retType2 == GTMType.VOID)
							mCode.append("\tdo &test13." + name + "(");
						else
							mCode.append("\tif $&test13." + name + "(");
						mCode.append("\"com/test/Test13\",\"" + name + "\")\n");
						mCode.append("\tquit\n\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append("\tpublic static " + retTypeWord + " " + name + "(Object[] args) {\n");
						if (retType1 != GTMType.VOID)
							builder.append("\t\treturn 0;\n");
						else
							builder.append("\t\treturn;\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					// combined response from M and Java
					@Override
					public String getMResponse() {
						if (retType1 == GTMType.VOID && retType2 != GTMType.VOID)
							return	"%YDB-E-XCVOIDRET, Attempt to return a value from function " +
									"gtm_xcj, which is declared void in external call table ./test13.xc\n";
						else if (retType1 != GTMType.VOID && retType2 == GTMType.VOID)
							return	"%YDB-E-JNI, Method (void)" + packagePrefix + testName + "." + name + " not found.\n";
						return "";
					}
				};
			}
		}

		writeTestCase(testCases, 13);
	}

	/*
	 * Test 14: Verify that strings of over 1MB are not allowed when returned from Java.
	 */
	public static void getTest14() throws Exception {
		final int[] types = new int[] {GTMType.GTM_STRING, GTMType.GTM_BYTE_ARRAY};
		final int type = types[TestCommon.rand.nextInt(types.length)];
		TestCase[] testCases = new TestCase[] {
			new TestCase("Test14", TestCase.CALL_OUT, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.OUTPUT_ONLY, type)) {
				@Override
				public String getMCode() {
					return	mHeader +
						incretrap +
						"\tset x=1\n" +
						"\tdo &test14." + name + "(\"com/test/Test14\",\"" + name + "\",.x)\n" +
						"\tquit\n\n";
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\tStringBuilder sb = new StringBuilder(1100000);\n");
					builder.append("\t\twhile (sb.length() < 1100000)\n");
					builder.append("\t\t\tsb.append(\"abcdefghijklmnopqrstuvwxyz\");\n");
					if (type == GTMType.GTM_STRING)
						builder.append("\t\tgtmString.value = sb.toString();\n");
					else
						builder.append("\t\tgtmByteArray.value = sb.toString().getBytes();\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return	"%YDB-E-JNI, Length of updated arg #1 to method " + packagePrefix + testName + "." + name + " exceeds the capacity of M variables.\n";
				}
			}
		};

		writeTestCase(testCases, 14);
	}

	/*
	 * Test 15: Verify that errors are issued if Java-call-out-incompatible argument types are used in the call-out table.
	 */
	public static void getTest15() throws Exception {
		final String[] types = new String[] {
			"gtm_int_t", "gtm_int_t *", "gtm_uint_t", "gtm_uint_t *", "gtm_long_t", "gtm_long_t *",
			"gtm_ulong_t", "gtm_ulong_t *", "gtm_float_t", "gtm_float_t *", "gtm_double_t", "gtm_double_t *",
			"gtm_char_t *", "gtm_string_t *" };
		int types_length = types.length;

		TestCase[] testCases = new TestCase[types_length];

		for (int typeIndex = 0; typeIndex < types_length; typeIndex++) {
			final String argType = types[typeIndex];
			testCases[typeIndex] = new TestCase("Test15", TestCase.CALL_OUT, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_ONLY, -1)) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tset $etrap=\"write $zstatus,!  set $ecode=\"\"\"\"\"\n");
					mCode.append("\tset x=123\n");
					mCode.append("\tdo &test15." + name + "(\"com/test/Test15\",\"" + name + "\",x)\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					return "150373858," + name + "+4^test15,%YDB-E-UNIMPLOP, Unimplemented construct encountered\n";
				}

				@Override
				public String getTableContent() {
					StringBuilder builder = new StringBuilder();
					builder.append(name);
					builder.append(":\tvoid gtm_xcj(I:");
					builder.append(argType);
					builder.append(")\n");
					return builder.toString();
				}
			};
		}

		writeTestCase(testCases, 15);
	}

	/*
	 * Test 16: Verify that errors are issued if invalid types are used. An "invalid" type may be a type
	 * that is not supported by GT.M at all, or one that is inappropriate for the Java call-out. Which case
	 * we deal with is reflected in the "unimplemented" array.
	 */
	public static void getTest16() throws Exception {
		final String[] types = new String[] {
			"gtm_char_t", "gtm_char_t **", "gtm_string_t", "gtm_pointertofunc_t", "gtm_pointertofunc_t *",
		 	"gtm_status_t", "gtm_status_t *", "gtm_jint_t *", "gtm_jlong_t *", "gtm_jfloat_t *", "gtm_jdouble_t *",
		 	"gtm_jboolean_t *", "gtm_jstring_t *", "gtm_jbyte_array_t *", "gtm_jbig_decimal_t *" };
		final boolean[] unimplemented = new boolean[] {
			false, true, false, true, true, true, false, false, false, false, false, false, false, false, false
		};
		// do one because if the call table parsing fails for the first label, it will keep failing at the same spot
		// for the subsequent cases
		int typeIndex = TestCommon.rand.nextInt(types.length);
		final String invalidType = types[typeIndex];
		final boolean unimplType = unimplemented[typeIndex];

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test16", TestCase.CALL_OUT, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.OUTPUT_ONLY, GTMType.GTM_INTEGER)) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tset $etrap=\"write $zstatus,!  set $ecode=\"\"\"\"\"\n");
					mCode.append("\tset x=123\n");
					mCode.append("\tdo &test16." + name + "(\"com/test/Test16\",\"" + name + "\",.x)\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getMResponse() {
					if (unimplType)
						return "150373858,lbl0+4^test16,%YDB-E-UNIMPLOP, Unimplemented construct encountered\n";
					else
						return "150376802,lbl0+4^test16,%YDB-E-ZCUNTYPE, Unknown type encountered\n";
				}

				@Override
				public String getTableContent() {
					StringBuilder builder = new StringBuilder();
					builder.append(name);
					builder.append(":\tvoid gtm_xcj(O:");
					builder.append(invalidType);
					builder.append(")\n");
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 16);
	}

	/*
	 * Test 17: Try setting arguments to values that exceed respective type capacities in Java or M.
	 */
	public static void getTest17() throws Exception {
		TestCase[] testCases = new TestCase[3];
		for (int i = 0; i < 3; i++) {
			final int testIndex = i;
			testCases[testIndex] = new TestCase("Test17", TestCase.CALL_OUT, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, testIndex == 0 ? GTMType.GTM_INTEGER : GTMType.GTM_LONG)) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					if (testIndex == 0)		// GTM_INTEGER
						mCode.append("\tset x=12345678901\n");
					else if (testIndex == 1)	// GTM_LONG
						mCode.append("\tset x=12345678901234567890\n");
					else 				// GTM_LONG
						mCode.append("\tset x=0\n");
					mCode.append("\tdo &test17." + name + "(\"com/test/Test17\",\"" + name + "\",.x)\n");
					if (testIndex == 2)
						mCode.append("\tif x'=\"" + Long.MAX_VALUE + "\" write \"mval overflown!\",!\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					if (testIndex == 0) {
						builder.append("\t\tif (gtmInteger.value != 12345678901L)\n");
						builder.append("\t\t\tSystem.out.println(\"GTMInteger overflown!\");\n");
					} else if (testIndex == 1) {
						builder.append("\t\tif (!gtmLong.toString().equals(\"12345678901234567890\"))\n");
						builder.append("\t\t\tSystem.out.println(\"GTMLong overflown!\");\n");
					} else {
						builder.append("\t\tgtmLong.value = Long.MAX_VALUE;\n");
					}
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					if (testIndex == 0)
						return "GTMInteger overflown!\n";
					else if (testIndex == 1)
						return "GTMLong overflown!\n";
					else
						return "";
				}
			};
		}

		writeTestCase(testCases, 17);
	}

	/*
	 * Test 18: Ensure appropriate conversion when passing alphanumeric values to numeric types.
	 */
	public static void getTest18() throws Exception {
		final String[] alphaNumValues = new String[] {
			"123", "123abc", "abc", "abc123"};
		final String[] expNumValues = new String[] {
			"123", "123", "0", "0"};
		final int alphaNumValuesLength = alphaNumValues.length;

		TestCase[] testCases = new TestCase[GTMType.BASIC_ARG_TYPES_LENGTH * alphaNumValuesLength];
		int testCasesIndex = 0;

		for (int argValueIndex = 0; argValueIndex < alphaNumValuesLength; argValueIndex++) {
			final String argValue = alphaNumValues[argValueIndex];
			final String expArgValue = expNumValues[argValueIndex];

			for (int argIndex = 0; argIndex < GTMType.BASIC_ARG_TYPES_LENGTH - 1; argIndex++) {
				final int argType = GTMType.BASIC_ARG_TYPES[argIndex];

				testCases[testCasesIndex++] = new TestCase("Test18", TestCase.CALL_OUT, GTMType.VOID,
						new GTMType(M.genVarName(false), GTMType.INPUT_ONLY, argType)) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append("\tset x=\"" + argValue + "\"\n");
						mCode.append("\tdo &test18." + name + "(\"com/test/Test18\",\"" + name + "\",x)\n");
						mCode.append("\tquit\n\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append(javaHeader);
						builder.append("\t\tSystem.out.println(");
						switch (argType) {
						case GTMType.GTM_BOOLEAN:
							builder.append("gtmBoolean");
							break;
						case GTMType.GTM_INTEGER:
							builder.append("gtmInteger");
							break;
						case GTMType.GTM_LONG:
							builder.append("gtmLong");
							break;
						case GTMType.GTM_FLOAT:
							builder.append("gtmFloat");
							break;
						case GTMType.GTM_DOUBLE:
							builder.append("gtmDouble");
							break;
						}
						builder.append(");\n");
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getJavaResponse() {
						String argValue;
						switch (argType) {
						case GTMType.GTM_BOOLEAN:
							argValue = expArgValue.equals("0") ? "false" : "true";
							break;
						case GTMType.GTM_INTEGER:
							argValue = expArgValue;
							break;
						case GTMType.GTM_LONG:
							argValue = expArgValue;
							break;
						case GTMType.GTM_FLOAT:
							argValue = expArgValue + ".0";
							break;
						case GTMType.GTM_DOUBLE:
							argValue = expArgValue + ".0";
							break;
						default:
							argValue = null;
						}
						return argValue + "\n";
					}
				};
			}
		}

		writeTestCase(testCases, 18);
	}

	/*
	 * Test 19: Ensure that assigning NULL to arguments or replacing them with new objects in Java does not affect the
	 * value of M variables.
	 */
	public static void getTest19() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH];
		int testCasesIndex = 0;

		for (int i = 0; i < 2; i++) {
			final boolean argNull = i == 1;

			for (int argIndex = 0; argIndex < GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH; argIndex++) {
				final int argType = GTMType.ALL_CALLOUT_ARG_TYPES[argIndex];

				if (!argNull && (argType != GTMType.GTM_STRING && argType != GTMType.GTM_BYTE_ARRAY))
					continue;

				// we are not dealing with String and byte[] because they are not appropriate for input-output args
				if (argType == GTMType.JAVA_STRING || argType == GTMType.JAVA_BYTE_ARRAY)
					continue;

				final String argInit;

				switch (argType) {
				case GTMType.GTM_BOOLEAN:
					argInit = "gtmBoolean = null;";
					break;
				case GTMType.GTM_INTEGER:
					argInit = "gtmInteger = null;";
					break;
				case GTMType.GTM_LONG:
					argInit = "gtmLong = null;";
					break;
				case GTMType.GTM_FLOAT:
					argInit = "gtmFloat = null;";
					break;
				case GTMType.GTM_DOUBLE:
					argInit = "gtmDouble = null;";
					break;
				case GTMType.GTM_STRING:
					argInit = "gtmString = " + (argNull ? "null" : "new GTMString(null)") + ";";
					break;
				case GTMType.GTM_BYTE_ARRAY:
					argInit = "gtmByteArray = " + (argNull ? "null" : "new GTMByteArray(null)") + ";";
					break;
				default:
					argInit = null;
				}

				testCases[testCasesIndex++] = new TestCase("Test19", TestCase.CALL_OUT, GTMType.VOID,
						new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, argType)) {
					@Override
					public String getMCode() {
						StringBuilder mCode = new StringBuilder();
						mCode.append(mHeader);
						mCode.append("\tset x=\"123\"\n");
						mCode.append("\tdo &test19." + name + "(\"com/test/Test19\",\"" + name + "\",.x)\n");
						mCode.append("\twrite x,!\n");
						mCode.append("\tquit\n\n");
						return mCode.toString();
					}

					@Override
					public String getJavaCode() {
						StringBuilder builder = new StringBuilder();
						builder.append(javaHeader);
						builder.append(argInit);
						builder.append("\t}\n");
						return builder.toString();
					}

					@Override
					public String getJavaResponse() {
						return (argType == GTMType.GTM_BOOLEAN) ? "1\n" :"123\n";
					}
				};
			}
		}

		writeTestCase(testCases, 19);
	}

	/*
	 * Test 20: Ensure that replacing the 'value' field with a NULL argument results in a proper error from JNI layer.
	 */
	public static void getTest20() throws Exception {
		TestCase[] testCases = new TestCase[2];

		for (int i = 0; i < 2; i++) {
			final int argType = i == 0 ? GTMType.GTM_STRING : GTMType.GTM_BYTE_ARRAY;

			testCases[i] = new TestCase("Test20", TestCase.CALL_OUT, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, argType)) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(incretrap);
					mCode.append("\tset x=\"123\"\n");
					mCode.append("\tdo &test20." + name + "(\"com/test/Test20\",\"" + name + "\",.x)\n");
					mCode.append("\twrite x,!\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					if (argType == GTMType.GTM_STRING)
						builder.append("\t\tgtmString.value = null;\n");
					else
						builder.append("\t\tgtmByteArray.value = null;\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return	"%YDB-E-JNI, Passing back a null reference in the 'value' field of arg #1 to method " + packagePrefix + testName + "." + name + ".\n" +
						"123\n";
				}
			};
		}

		writeTestCase(testCases, 20);
	}

	/*
	 * Test 21: Ensure that IO arguments come back intact if never modified in Java.
	 */
	public static void getTest21() throws Exception {
		TestCase[] testCases = new TestCase[GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH - 2];
		int testCasesIndex = 0;

		for (int argIndex = 0; argIndex < GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH; argIndex++) {
			final int argType = GTMType.ALL_CALLOUT_ARG_TYPES[argIndex];

			if (argType == GTMType.JAVA_STRING || argType == GTMType.JAVA_BYTE_ARRAY)
				continue;

			testCases[testCasesIndex++] = new TestCase("Test21", TestCase.CALL_OUT, GTMType.VOID,
					new GTMType(M.genVarName(false), GTMType.INPUT_OUTPUT, argType)) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(incretrap);
					mCode.append("\tset x=1\n");
					mCode.append("\tdo &test21." + name + "(\"com/test/Test21\",\"" + name + "\",.x)\n");
					mCode.append("\twrite x,!\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return "1\n";
				}
			};
		}

		writeTestCase(testCases, 21);
	}

	/*
	 * Test 22: Ensure that passing up to 50 JVM options, excluding '-Xrs' and '-Djava.class.path', works as expected.
	 */
	public static void getTest22() throws Exception {
		String setGTMXCJVMOptions =
				"if ($?GTMXC_jvm_options) then\n" +
				"\tsetenv old_GTMXC_jvm_options $GTMXC_jvm_options\n" +
				"endif\n"+
				"setenv GTMXC_jvm_options \"" +
				"-Dtest.value1=1 -Dtest.value2=2 -Xrs -Dtest.value3 " +
				"-Xrsabc -Xrscba -DA -DD -D=123 -Dtest -Dvalue4\t-DD=D|"+
				"-Djava.class.path=/tmp\t-Dtest.value5=5|-Dtest.value6=6|" +
				"-Djava.class.pathhhh=/tmp -Dhelp  -DXrs " +
				"-Dt0=0 -Dt1=1 -Dt2=2 -Dt3=3 -Dt4=4 -Dt5=5 -Dt6=6 -Dt7=7 -Dt8=8 -Dt9=9 " +
				"-Dt10=10 -Dt11=11 -Dt12=12 -Dt13=13 -Dt14=14 -Dt15=15 -Dt16=16 -Dt17=17 -Dt18=18 -Dt19=19 " +
				"-Dt20=20 -Dt21=21 -Dt22=22 -Dt23=23 -Dt24=24 -Dt25=25 -Dt26=26 -Dt27=27 -Dt28=28 -Dt29=29 " +
				"-Dt30=30 -Dt31=31 -Dt32=32 -Dt33=33 -Dt34=34 -Dt35=35 -Dt36=36 -Dt37=37 -Dt38=38 -Dt39=39 " +
				"\"\n";
		String unsetGTMXCJVMOptions =
				"if ($?old_GTMXC_jvm_options) then\n" +
				"\tsetenv GTMXC_jvm_options $old_GTMXC_jvm_options\n" +
				"else\n" +
				"\tunsetenv GTMXC_jvm_options\n" +
				"endif\n";

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test22", TestCase.CALL_OUT, GTMType.VOID) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tdo &test22." + name + "(\"com/test/Test22\",\"" + name + "\")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append(javaHeader);
					builder.append("\t\tRuntimeMXBean RuntimemxBean = ManagementFactory.getRuntimeMXBean();\n");
					builder.append("\t\tList<String> arguments = RuntimemxBean.getInputArguments();\n");
					builder.append("\t\tfor (String argument : arguments) {\n");
					builder.append("\t\t\tSystem.out.println(argument);\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					return	"-Dgtm.callouts=1\n" +
						"-Xrs\n" +
						"-Dtest.value1=1\n" +
						"-Dtest.value2=2\n" +
						"-Dtest.value3\n" +
						"-DA\n" +
						"-DD\n" +
						"-D=123\n" +
						"-Dtest\n" +
						"-Dvalue4\t-DD=D\n" +
						"-Dtest.value6=6\n" +
						"-Dhelp\n" +
						"-DXrs\n" +
						"-Dt0=0\n-Dt1=1\n-Dt2=2\n-Dt3=3\n-Dt4=4\n-Dt5=5\n" +
						"-Dt6=6\n-Dt7=7\n-Dt8=8\n-Dt9=9\n-Dt10=10\n" +
						"-Dt11=11\n-Dt12=12\n-Dt13=13\n-Dt14=14\n-Dt15=15\n" +
						"-Dt16=16\n-Dt17=17\n-Dt18=18\n-Dt19=19\n-Dt20=20\n" +
						"-Dt21=21\n-Dt22=22\n-Dt23=23\n-Dt24=24\n-Dt25=25\n" +
						"-Dt26=26\n-Dt27=27\n-Dt28=28\n-Dt29=29\n-Dt30=30\n" +
						"-Dt31=31\n-Dt32=32\n-Dt33=33\n-Dt34=34\n-Dt35=35\n";
				}
			}
		};

		writeTestCase(testCases, 22,
			destDir + "test22.env", setGTMXCJVMOptions,
			destDir + "test22.noenv", unsetGTMXCJVMOptions);
	}

	/*
	 * Test 23: Expect to receive a default primitive or Object value in Java when the respective M argument is missing.
	 */
	public static void getTest23() throws Exception {
		final int numOfFormals = 2 + TestCommon.rand.nextInt(28);

		final GTMType[] formals = new GTMType[numOfFormals];

		final String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfFormals; i++)
		{
			// GTMString and GTMByteArray are only used for input-output and output-only directions;
			// the native String and byte[] are only used forinput-only direction, so adjust accordingly.
			int direction;
			int type = GTMType.ALL_CALLOUT_ARG_TYPES[TestCommon.rand.nextInt(GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH)];
			if (type == GTMType.GTM_STRING || type == GTMType.GTM_BYTE_ARRAY) {
				while (GTMType.INPUT_ONLY == (direction = GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)]));
			} else if (type == GTMType.JAVA_STRING || type == GTMType.JAVA_BYTE_ARRAY) {
				direction = GTMType.INPUT_ONLY;
			} else {
				direction = GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)];
			}
			formals[i] = new GTMType(varNameBase + i, direction, type);
		}

		final boolean[] provided = new boolean[numOfFormals];
		provided[numOfFormals - 1] = true;

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test23", TestCase.CALL_OUT, GTMType.VOID, formals) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tdo &test23." + name + "(\"com/test/Test23\",\"" + name + "\"");
					for (int i = 0; i < numOfFormals - 1; i++) {
						mCode.append(",");
						if (TestCommon.rand.nextBoolean()) {
							provided[i] = true;
							mCode.append(i + 65);
						}
					}
					mCode.append(",");
					mCode.append((numOfFormals - 1 + 65) + ")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("\tpublic static void " + name + "(Object[] args) {\n");
					builder.append("\t\ttry {\n");
					for (int i = 0; i < numOfFormals; i++) {
						if (formals[i].type == GTMType.JAVA_BYTE_ARRAY)
							builder.append("\t\t\tSystem.out.println(new String((" + GTMType.JAVA_ARG_TYPE_NAMES[GTMType.JAVA_BYTE_ARRAY] + ")args[" + i + "]));\n");
						else
							builder.append("\t\t\tSystem.out.println((" + GTMType.JAVA_ARG_TYPE_NAMES[formals[i].type] + ")args[" + i + "]);\n");
					}
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					StringBuilder builder = new StringBuilder();
					for (int i = 0; i < numOfFormals; i++) {
						String out = "";
						int type = formals[i].type;

						switch (type) {
						case GTMType.GTM_BOOLEAN:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY || !provided[i]) ? "false" : "true";
							break;
						case GTMType.GTM_INTEGER:
						case GTMType.GTM_LONG:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY || !provided[i]) ? "0" : (i + 65) + "";
							break;
						case GTMType.GTM_FLOAT:
						case GTMType.GTM_DOUBLE:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY || !provided[i]) ? "0.0" : (i + 65) + ".0";
							break;
						case GTMType.GTM_STRING:
						case GTMType.GTM_BYTE_ARRAY:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY || !provided[i]) ? "" : (i + 65) + "";
							break;
						case GTMType.JAVA_STRING:
						case GTMType.JAVA_BYTE_ARRAY:
							out = (!provided[i]) ? "" : (i + 65) + "";
							break;
						}

						builder.append(out);
						builder.append("\n");
					}
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 23);
	}

	/*
	 * Test 24: Expect to receive an error when an M argument is an undefined variable.
	 */
	public static void getTest24() throws Exception {
		final int numOfFormals = 2 + TestCommon.rand.nextInt(28);

		final GTMType[] formals = new GTMType[numOfFormals];

		final String varNameBase = M.genVarName(false);
		for (int i = 0; i < numOfFormals; i++)
		{
			// GTMString and GTMByteArray are only used for input-output and output-only directions;
			// the native String and byte[] are only used forinput-only direction, so adjust accordingly.
			int direction;
			int type = GTMType.ALL_CALLOUT_ARG_TYPES[TestCommon.rand.nextInt(GTMType.ALL_CALLOUT_ARG_TYPES_LENGTH)];
			if (type == GTMType.GTM_STRING || type == GTMType.GTM_BYTE_ARRAY) {
				while (GTMType.INPUT_ONLY == (direction = GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)]));
			} else if (type == GTMType.JAVA_STRING || type == GTMType.JAVA_BYTE_ARRAY) {
				direction = GTMType.INPUT_ONLY;
			} else {
				direction = GTMType.DIRECTIONS[TestCommon.rand.nextInt(GTMType.DIRECTIONS_LENGTH)];
			}
			formals[i] = new GTMType(varNameBase + i, direction, type);
		}

		final String undefVar = M.genVarName(false);
		final boolean[] error = new boolean[1];

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test24", TestCase.CALL_OUT, GTMType.VOID, formals) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append(incretrap);
					mCode.append("\tdo &test24." + name + "(\"com/test/Test24\",\"" + name + "\"");
					for (int i = 0; i < numOfFormals - 1; i++) {
						mCode.append(",");
						if (TestCommon.rand.nextBoolean()) {
							mCode.append(i + 65);
						} else {
							if (TestCommon.rand.nextBoolean())
								mCode.append(".");
							mCode.append(undefVar);
							if (formals[i].direction != GTMType.OUTPUT_ONLY)
								error[0] = true;
						}
					}
					mCode.append(",");
					mCode.append((numOfFormals - 1 + 65) + ")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("\tpublic static void " + name + "(Object[] args) {\n");
					builder.append("\t\ttry {\n");
					for (int i = 0; i < numOfFormals; i++) {
						if (formals[i].type == GTMType.JAVA_BYTE_ARRAY)
							builder.append("\t\t\tSystem.out.println(new String((" + GTMType.JAVA_ARG_TYPE_NAMES[GTMType.JAVA_BYTE_ARRAY] + ")args[" + i + "]));\n");
						else
							builder.append("\t\t\tSystem.out.println((" + GTMType.JAVA_ARG_TYPE_NAMES[formals[i].type] + ")args[" + i + "]);\n");
					}
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}

				@Override
				public String getJavaResponse() {
					StringBuilder builder = new StringBuilder();

					if (error[0]) {
						builder.append("%YDB-E-LVUNDEF, Undefined local variable: " + undefVar + "\n");
						return builder.toString();
					}

					for (int i = 0; i < numOfFormals; i++) {
						String out = "";
						int type = formals[i].type;

						switch (type) {
						case GTMType.GTM_BOOLEAN:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY) ? "false" : "true";
							break;
						case GTMType.GTM_INTEGER:
						case GTMType.GTM_LONG:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY) ? "0" : (i + 65) + "";
							break;
						case GTMType.GTM_FLOAT:
						case GTMType.GTM_DOUBLE:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY) ? "0.0" : (i + 65) + ".0";
							break;
						case GTMType.GTM_STRING:
						case GTMType.GTM_BYTE_ARRAY:
							out = (formals[i].direction == GTMType.OUTPUT_ONLY) ? "" : (i + 65) + "";
							break;
						case GTMType.JAVA_STRING:
						case GTMType.JAVA_BYTE_ARRAY:
							out = (i + 65) + "";
							break;
						}

						builder.append(out);
						builder.append("\n");
					}
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 24);
	}

	/*
	 * Test 26: Ensure that assigning an intrinsic special variable to an I/O M argument does not cause segmentation
	 * violations due to attempted operations on read-only memory.
	 */
	public static void getTest25() throws Exception {
		final int numOfArgs = 29;

		GTMType[] args = new GTMType[numOfArgs];
		final String varNameBase = M.genVarName(false);
		for (int i = 1; i <= numOfArgs; i++)
			args[i - 1] = new GTMType(varNameBase + i, GTMType.INPUT_OUTPUT, GTMType.GTM_STRING);

		TestCase[] testCases = new TestCase[] {
			new TestCase("Test25", TestCase.CALL_OUT, GTMType.VOID, args) {
				@Override
				public String getMCode() {
					StringBuilder mCode = new StringBuilder();
					mCode.append(mHeader);
					mCode.append("\tzshow \"I\":a\n");
					mCode.append("\tset length=+$order(a(\"I\",\"\"),-1)\n");
					mCode.append("\tfor i=1:1:" + numOfArgs + " set setCommand=\"x\"_i_\"=\"_$piece(a(\"I\",$random(length)+1),\"=\",1) set @setCommand\n");
					mCode.append("\tdo &test25." + name + "(\"com/test/Test25\",\"" + name + "\"");
					for (int i = 1; i <= numOfArgs; i++)
						mCode.append(",.x" + i);
					mCode.append(")\n");
					mCode.append("\tquit\n\n");
					return mCode.toString();
				}

				@Override
				public String getJavaCode() {
					StringBuilder builder = new StringBuilder();
					builder.append("\tpublic static void " + name + "(Object[] args) {\n");
					builder.append("\t\ttry {\n");
					for (int i = 0; i < numOfArgs; i++)
						builder.append("\t\t\t((GTMString)args[" + i + "]).value = \"abcdefg\";\n");
					builder.append("\t\t} catch (Exception e) {\n");
					builder.append("\t\t\tSystem.out.println(e.getMessage());\n");
					builder.append("\t\t}\n");
					builder.append("\t}\n");
					return builder.toString();
				}
			}
		};

		writeTestCase(testCases, 25);
	}

	public static void writeTestCase(TestCase[] testCases, int number) {
		writeTestCase(testCases, number, null, null, null, null);
	}

	public static void writeTestCase(TestCase[] testCases, int number,
			String envSetFile, String envSetCommands,
			String envUnsetFile, String envUnsetCommands) {
		TestCase.write("Test" + number,
			testCases,
			destDir + "com/test/Test" + number + ".java",
			destDir + "test" + number + ".m",
			destDir + "test" + number + ".xc",
			destDir + "test" + number + ".cmp",
			envSetFile,
			envSetCommands,
			envUnsetFile,
			envUnsetCommands);
	}

	public static void main(String[] args) throws Exception {
		destDir = args[0];
		getTest1();
		getTest2();
		getTest3();
		getTest4();
		getTest5();
		getTest6();
		getTest7();
		getTest8();
		getTest9();
		getTest10();
		getTest11();
		getTest12();
		getTest13();
		getTest14();
		getTest15();
		getTest16();
		getTest17();
		getTest18();
		getTest19();
		getTest20();
		getTest21();
		getTest22();
		getTest23();
		getTest24();
		getTest25();
	}
}
