package co.luminositylabs.oss.testing.nio2;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.Test;

/**
 * Experiment A Test Class - Used for testing JUnit-TestNG-Surefire-Failsafe
 */
public class ExperimentATest {

    /** The static logger instance. */
    private static final Logger logger = LoggerFactory.getLogger(ExperimentATest.class);

    @Test(groups = {"A", "1"})
    public void test1() {
        logger.debug("doing test 1");
    }

    @Test
    public void commonTest() {
        logger.debug("doing common test");
    }

    class InnerClassA {
        @Test
        public void innerClassATest1() {
            logger.debug("doing innerClassATest1");
        }
    }

    class InnerClassB {
        @Test
        public void innerClassBTest1() {
            logger.debug("doing innerClassBTest1");
        }
    }

    class InnerClassC {
        @Test
        public void innerClassCTest1() {
            logger.debug("doing innerClassCTest1");
        }
    }
}
