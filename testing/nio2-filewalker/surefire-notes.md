2026-10-31
main/jdk25 branch (jdk25 bytecode)
surefire/failsafe maven plugins v3.6.1
plugin management + plugins sections do NOT have surefire/failsafe configs for testng suite xml file
===============
after updating to surefire/failsafe v3.6.0, the testng suite xml config was removed and replaced with the following:
```
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <configuration>
            <includes>
                <include>DisableDefaultIncludesBySpecifyingThisNonexistentStubClass</include>
            </includes>
            <includesFile>${project.build.testOutputDirectory}/surefire-tests.lst</includesFile>
        </configuration>
    </plugin>
```
The result:
1. The <includes> config with the single <include> element causes surefire to ONLY include the specified stub class, 
 which does not actually exist.
2. The followup includesFile config points to a text file containing a list of explicit includes.

With this configuration, essentially the only tests that run are the ones explicitly defined by the lst file.

TEST: If the <includes>...<include>... configuration section is not specified, will tests other than the ones explicitly
listed in the lst file be run?
RESULT: No

TEST: If a JUnit Suite file is configured, will tests other than what is specified in the suite file be run?
RESULT:  surefire/failsafe default include patterns do not include "Suite" expressions specifically.  It's either
necessary to configure an expression in an <include> element within the <includes> element, or place an expression in
a file specified with <includesFile>.

TEST: Do group dependencies work across tests?
RESULT: YES, they do.

TEST: Do method dependencies work across tests?
RESULT: YES, they do, but the method expressions appear to NOT be documented very well:
1. When only specifying a method name, and that method name does not actually exist, what happens?
error: "TestEngine with ID 'junit-platform-suite' failed to discover tests"
2. When only specifying a method name, does it correspond to ALL instances of that method name across all test classes?
It seems it corresponds to all
3. Referencing the shortname for a class, following by a period, followed by a method name doesn't appear to work.
4. Referencing the fully qualified class name, following by a period, followed by a method name DOES appear to work.

TEST: in all these separate cases, does a failed method properly skip all dependent tests?
====
is org.junit.jupiter:junit-jupiter artifact transitively imported by org.junit.platform:junit-platform-suite artifact ?
Test to see if declaring the later without the former allows running a junit based test in addition to delcaring a junit suite class.

The surefire <includedFile> list can address specific methods of specific test classes via the following syntax:
co.luminositylabs.oss.testing.ExperimentCTest#test2
Does this work?  Is there an equivalent way to address methods in a junit test suite class?  Is there a similar addressing scheme for nested classes?


Surefire/Failsafe includes can reference test methods using the `#` char but the matching rules are not intuitive.

JUnit suite classes can specify test methods specifically.
The method name vales must use their fully qualified class names.
Example:
```
@SelectMethod("co.luminositylabs.oss.testing.nio2.ExperimentATest#commonTest")
```

