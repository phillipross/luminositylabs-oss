package co.luminositylabs.oss.testing.nio2;

import org.junit.platform.suite.api.SelectClasses;
import org.junit.platform.suite.api.SelectMethod;
import org.junit.platform.suite.api.Suite;

@Suite
//@SelectClasses({ ExperimentATest.class, FileWalkTest.class, ExperimentCTest.class,ExperimentBTest.class})
//@SelectClasses(names = {"co.luminositylabs.oss.testing.nio2.ExperimentATest", "co.luminositylabs.oss.testing.nio2.FileWalkTest", "co.luminositylabs.oss.testing.nio2.ExperimentCTest", "co.luminositylabs.oss.testing.nio2.ExperimentBTest"})
//@SelectMethod("co.luminositylabs.oss.testing.nio2.ExperimentATest#commonTest")
//@SelectClasses({ ExperimentATest.class, ExperimentATest.InnerClassA.class})
@SelectMethod("co.luminositylabs.oss.testing.nio2.ExperimentATest$InnerClassA#innerClassATest1")
@SelectMethod("co.luminositylabs.oss.testing.nio2.ExperimentATest$InnerClassB#innerClassBTest1")
public class ExperimentATestSuite {
}
