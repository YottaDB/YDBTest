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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;

/**
 * The "workhorse" of GTMJI testing, a template for a test entity, with automated generation of M and Java
 * source code components as well as definition table and expected output files.
 *
 * All tests within TestCI and TestXC classes roughly follow the same template format for generated M and
 * Java files.
 *
 * CALLOUTS:
 * --------
 *
 * M file:
 *
 *	test1
 *	  do lbl0					;\
 *	  ...						; } invokes individual test cases
 *	  do lbln					;/
 *	  quit
 *
 *	lbl0
 *	  write "#########",!,"lbl0",!,"#########",!	; prints label header for easy test debugging
 *	  set x=0					; optional setup for arguments and other things to test
 *	  do &test1.lbl0("com/test/Test1","lbl0",x)	; invocation of the Java code by class and method name;
 *	  						;   if a return value is expected, the invocation looks like
 *	  						;   set ret=$&test1.lbl0(...)
 *	  write "The argument upon return is "_x,!	; optional post-return statements
 *	  quit
 *
 *	...						;\
 *							; |
 *	lbln						; |
 *	  write "#########",!,"lbln",!,"#########",!	; |
 *	  set x=0					;  > various other test cases
 *	  do &test1.lbln("com/test/Test1","lbln",x)	; |
 *	  write "The argument upon return is "_x,!	; |
 *	  quit						;/
 *
 * Java file:
 *
 *	package com.test;						// mandates the package
 *
 *	import com.fis.gtm.ji.*;					// \
 *	import java.math.BigDecimal;					//  } imports necessary packages for the test to work
 *	import java.text.DecimalFormat;					// /
 *
 *	public class Test1 {
 *		public static final DecimalFormat floatFormat = 	// predefined output format for floats
 *			new DecimalFormat(".######");
 *		public static final DecimalFormat doubleFormat = 	// predefined output format for doubles
 *			new DecimalFormat(".###############");
 *
 *		public static long lbl0(Object[] args) {		// function signatures differ only in return type
 *			GTMInteger gtmInteger = (GTMInteger)args[0];	// a set of casts to respective argument types
 *			System.out.println(gtmInteger);			// optional prints of received values
 *			gtmInteger.value = 123;				// optional argument modification and other test logic
 *			return -718525476L;				// optional return type
 *		}
 *
 *		...							// \
 *									// |
 *		public static void lbln(Object[] args) {		// |
 *			GTMBoolean gtmBoolean = (GTMBoolean)args[0];	//  > various other test cases
 *			System.out.println(gtmBoolean);			// |
 *			gtmBoolean.value = !gtmBoolean.value;		// |
 *		}							// /
 *	}
 *
 *
 * CALLINS:
 * -------
 *
 * M file:
 *
 *	lbl0(losepdg)			; each label has a set of args with randomly generated names
 *	  write losepdg,!		; optional writes of the received arguments
 *	  set losepdg=losepdg/10	; optional argument modification and other test logic
 *	  quit				; quit, optionally with a value
 *
 *	...				;\
 *					; |
 *	lbln(tiegg)			;  \ various other test cases
 *	  write tiegg,!			;  /
 *	  set tiegg=tiegg/10		; |
 *	  quit 1239636861		;/
 *
 * Java file:
 *
 *	package com.test;							// mandates the package
 *
 *	import com.fis.gtm.ji.*;						// \
 *	import java.math.BigDecimal;						//  } imports necessary packages for the test to work
 *	import java.text.DecimalFormat;						// /
 *
 *	public class Test1 {
 *		public static final DecimalFormat floatFormat = 		// predefined output format for floats
 *			new DecimalFormat(".######");
 *		public static final DecimalFormat doubleFormat = 		// predefined output format for doubles
 *			new DecimalFormat(".###############");
 *
 *		public static void main(String[] args) {			// \
 *			lbl0();							// |
 *			...							//  > the main method that invokes all individual test cases
 *			lbln();							// |
 *		}								// /
 *
 *		public static void lbl0() {
 *			System.out.println("#######\nlbl0\n#######");		// prints label header for easy debugging
 *			try {
 *				GTMBoolean x = new GTMBoolean(true);		// set of argument initializations for the call-in
 *				GTMCI.doVoidJob("lbl0", x);			// call-in invocation with the expected return type reflected in
 *										//   the doXXXJob function name; the first arguments is the name
 *										//   of the mapping for M function defined in the call-in table
 *				System.out.println("Arg upon return is " + x);	// optional prints of arguments upon return
 *			} catch (Exception e) {					// \
 *				System.out.println(e.getMessage());		//  } in case M call errored out, handle the exception
 *			}							// /
 *		}
 *
 *		...								// \
 *										//  |
 *		public static void lbln() {					//  |
 *			System.out.println("#######\nlbln\n#######");		//  |
 *			try {							//  |
 *				GTMBoolean x = new GTMBoolean(true);		//  |
 *				System.out.println("Job returned " +		//   > various other test cases
 *					GTMCI.doBooleanJob("lbln", x));		//  |
 *				System.out.println("Arg upon return is " + x);	//  |
 *			} catch (Exception e) {					//  |
 *				System.out.println(e.getMessage());		//  |
 *			}							//  |
 *		}								// /
 *	}
 *
 */
public abstract class TestCase {
	// flags to indicate whether it is call-ins or call-outs we are dealing with
	public static final int CALL_IN = 0, CALL_OUT = 1;

	String testName;	// holds the name of the test group (such as 'Test3')z
	String name;		// holds the name of the test (such as 'lbl4')
	boolean callin;		// indicates whether it is a call-in or call-out test
	int ret;		// points to the type of the return value (obtained from GTMType-contained constants)
	int numOfArgs;		// the number of arguments
	GTMType[] args;		// the arguments to the Java or M routine

	String mHeader = "";	// stores the pre-generated M label header (based on name, number, and type of args)
	String javaHeader = "";	// stores the pre-generated Java method header (based on name, number, and type of args)

	static final String LABEL = "lbl";	// prefix for names of all test cases
	static int index = 0;			// internally maintained index for

	public TestCase(String testName, int direction, int ret, GTMType... args) {
		this.testName = testName;
		this.name = LABEL + index++;
		this.ret = ret;
		this.args = args;
		this.numOfArgs = args.length;
		this.callin = direction == CALL_IN;
		this.mHeader = getMLabelHeader();
		this.javaHeader = getJavaMethodHeader();
	}

	/* Generate the M label header based on the argument list provided. */
	private String getMLabelHeader() {
		StringBuilder builder = new StringBuilder();
		builder.append(name);
		if (callin) {
			if (numOfArgs > 0 || ret != GTMType.VOID)
				builder.append("(");
			if (numOfArgs > 0) {
				for (int i = 0; i < numOfArgs; i++) {
					if (i != 0)
						builder.append(",");
					builder.append(args[i].name);
				}
			}
			if (numOfArgs > 0 || ret != GTMType.VOID)
				builder.append(")");
		} else {
			builder.append("\n\twrite \"###################\",!,\"" + name + "\",!,\"###################\",!");
		}
		builder.append("\n");
		return builder.toString();
	}

	/* Generate the Java label header based on the argument list provided. */
	private String getJavaMethodHeader() {
		StringBuilder builder = new StringBuilder();
		if (callin) {
			builder.append("\tpublic static void " + name + "() {\n");
			builder.append("\t\tSystem.out.println(\"###################\\n" + name + "\\n###################\");\n");
		} else {
			builder.append("\tpublic static ");
			if (ret == GTMType.GTM_LONG)
				builder.append("long");
			else if (ret == GTMType.GTM_STATUS)
				builder.append("int");
			else
				builder.append("void");
			builder.append(" " + name + "(Object[] args) {\n");
			for (int i = 0; i < numOfArgs; i++) {
				if (args[i].type >= 0) {
					args[i].name = GTMType.JAVA_ARG_NAMES[args[i].type];
					builder.append("\t\t" + J.genArgCast(args[i].name, GTMType.JAVA_ARG_TYPE_NAMES[args[i].type], i) + "\n");
				}
			}
		}
		return builder.toString();
	}

	/* Generate the M label code (needs to be implemented). */
	public abstract String getMCode();

	/* Produce the expected M response (default is empty string). */
	public String getMResponse() {
		return "";
	}

	/* Generate the Java method code (needs to be implemented). */
	public abstract String getJavaCode();

	/* Produce the expected Java response (default is empty string). */
	public String getJavaResponse() {
		return "";
	}

	/* Produce the commands for setting the test environment. */
	public String getEnvSetting() {
		return null;
	}

	/* Produce the commands for unsetting the test environment. */
	public String getEnvUnsetting() {
		return null;
	}

	/* Generate the call-in or call-out mapping table. */
	public String getTableContent() {
		StringBuilder builder = new StringBuilder();
		// label name in M
		builder.append(name + ":\t");
		// return type (+2 is because GTM_STATUS and VOID have negative values)
		builder.append(GTMType.TABLE_RET_TYPES[ret + 2]);
		// method name in C (JNI layer)
		if (callin)
			builder.append(" " + name + "^" + testName.toLowerCase());
		else
			builder.append(" gtm_xcj");
		builder.append("(");
		// argument list
		if (numOfArgs > 0) {
			for (int i = 0; i < numOfArgs; i++) {
				if (i != 0)
					builder.append(",");
				if (args[i].direction == GTMType.INPUT_ONLY)
					builder.append("I");
				else if (args[i].direction == GTMType.OUTPUT_ONLY)
					builder.append("O");
				else
					builder.append("IO");
				builder.append(":");
				builder.append(GTMType.TABLE_ARG_TYPES[args[i].type]);
			}
		}
		builder.append(")");
		builder.append("\n");
		return builder.toString();
	}

	/* Function reserved for debugging of test generation. */
	public void print() {
		System.out.println("M code:");
		System.out.println(getMCode());
		System.out.println("Java code:");
		System.out.println(getJavaCode());
		System.out.println("Expected M response:");
		System.out.println(getMResponse());
		System.out.println("Expected Java response:");
		System.out.println(getJavaResponse());
		System.out.println("-----------------------------------");
	}

	/* Prepare a writer for the specified file (ensures the path existence and proper encoding). */
	private static BufferedWriter getWriter(String file) {
		try {
			new File(new File(file).getParent()).mkdirs();

			return new BufferedWriter(new OutputStreamWriter(new FileOutputStream(file),"UTF-8"));
		} catch (IOException e) {
			e.printStackTrace();
		}

		return null;
	}

	/* Write the Java class to a file, taking care of necessary imports and function invocations from main(). */
	private static void writeJavaClass(String className, String javaFile, String javaMethods, boolean callin) throws IOException {
		StringBuilder classBuilder = new StringBuilder();
		classBuilder.append("package com.test;\n\n");
		classBuilder.append("import com.fis.gtm.ji.*;\n\n");
		/* The following two imports are needed to get the list of current JVM options. */
		classBuilder.append("import java.lang.management.ManagementFactory;\n");
		classBuilder.append("import java.lang.management.RuntimeMXBean;\n");
		classBuilder.append("import java.math.BigDecimal;\n");
		classBuilder.append("import java.text.DecimalFormat;\n");
		classBuilder.append("import java.util.List;\n\n");
		classBuilder.append("public class " + className + " {\n");
		classBuilder.append("\tpublic static final DecimalFormat floatFormat = new DecimalFormat(\".######\");\n");
		classBuilder.append("\tpublic static final DecimalFormat doubleFormat = new DecimalFormat(\".###############\");\n\n");
		if (callin) {
			classBuilder.append("\tpublic static void main(String[] args) {\n");
			for (int i = 0; i < index; i++)
				classBuilder.append("\t\t" + LABEL + i + "();\n");
			classBuilder.append("\t}\n\n");
		}
		classBuilder.append(javaMethods);
		classBuilder.append("}");

		BufferedWriter writer = getWriter(javaFile);
		writer.write(classBuilder.toString());
		writer.close();
	}

	/* Write the M routine to a file, taking care of label invocations from the header label. */
	private static void writeMRoutine(String routineName, String mFile, String mLabels, boolean callin) throws IOException {
		StringBuilder mBuilder = new StringBuilder();
		if (!callin) {
			mBuilder.append(routineName.toLowerCase() + "\n");
			for (int i = 0; i < index; i++)
				mBuilder.append("\tdo " + LABEL + i + "\n");
			mBuilder.append("\tquit\n");
		}
		mBuilder.append(mLabels);

		BufferedWriter writer = getWriter(mFile);
		writer.write(mBuilder.toString());
		writer.close();
	}

	/* Write the call-in or call-out table to a file. */
	private static void writeTable(String tableFile, String tableEntries, boolean callin) throws IOException {
		StringBuilder mBuilder = new StringBuilder();
		if (!callin)
			mBuilder.append("/usr/library/com/gtmji/libgtmm2j.so\n");
		mBuilder.append(tableEntries);

		BufferedWriter writer = getWriter(tableFile);
		writer.write(mBuilder.toString());
		writer.close();
	}

	/* Write the expected combined (M + Java) response from the test to a file. */
	private static void writeResponse(String responseFile, String responses) throws IOException {
		BufferedWriter writer = getWriter(responseFile);
		writer.write(responses);
		writer.close();
	}

	/* Write the environment setting/unsetting commands. */
	private static void writeEnv(String envFile, String commands) throws IOException {
		BufferedWriter writer = getWriter(envFile);
		writer.write(commands);
		writer.close();
	}

	/* Wrapper function for write in case no environment-setting commands are used. */
	public static void write(String testName, TestCase[] testCases, String javaFile, String mFile, String tableFile, String responseFile) {
		write(testName, testCases, javaFile, mFile, tableFile, responseFile, null, null, null, null);
	}

	/* Write the M and Java code, mapping table, and expected output to their respective files. */
	public static void write(String testName, TestCase[] testCases, String javaFile, String mFile, String tableFile, String responseFile,
			String envSettingFile, String envSettingCommands, String envUnsettingFile, String envUnsettingCommands) {
		// Java code
		StringBuilder builder = new StringBuilder();
		for (int i = 0; i < index; i++)
			builder.append(testCases[i].getJavaCode());
		try {
			writeJavaClass(testName, javaFile, builder.toString(), testCases[0].callin);
		} catch (IOException e) {
			e.printStackTrace();
		}

		// M code
		builder = new StringBuilder();
		for (int i = 0; i < index; i++)
			builder.append(testCases[i].getMCode());
		try {
			writeMRoutine(testName, mFile, builder.toString(), testCases[0].callin);
		} catch (IOException e) {
			e.printStackTrace();
		}

		// mapping table
		builder = new StringBuilder();
		for (int i = 0; i < index; i++)
			builder.append(testCases[i].getTableContent());
		try {
			writeTable(tableFile, builder.toString(), testCases[0].callin);
		} catch (IOException e) {
			e.printStackTrace();
		}

		// response file
		builder = new StringBuilder();
		for (int i = 0; i < index; i++) {
			builder.append("###################\n" + testCases[i].name + "\n###################\n");
			if (testCases[0].callin) {
				builder.append(testCases[i].getMResponse());
				builder.append(testCases[i].getJavaResponse());
			} else {
				builder.append(testCases[i].getJavaResponse());
				builder.append(testCases[i].getMResponse());
			}
		}
		try {
			writeResponse(responseFile, builder.toString());
		} catch (IOException e) {
			e.printStackTrace();
		}

		// environment files
		if (envSettingCommands != null) {
			try {
				writeEnv(envSettingFile, envSettingCommands);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		if (envUnsettingCommands != null) {
			try {
				writeEnv(envUnsettingFile, envUnsettingCommands);
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		// reset the label index for the next test group
		index = 0;
	}
}
