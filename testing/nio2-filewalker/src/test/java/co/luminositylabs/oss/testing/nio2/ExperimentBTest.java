package co.luminositylabs.oss.testing.nio2;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.annotations.Test;

/**
 * Experiment B Test Class - Used for testing JUnit-TestNG-Surefire-Failsafe
 */
public class ExperimentBTest {

    /** The static logger instance. */
    private static final Logger logger = LoggerFactory.getLogger(ExperimentBTest.class);

    @Test(groups = {"B", "1"}, dependsOnGroups = {"A"})
    public void test1() {
        logger.debug("doing test 1");
    }

    @Test
    public void commonTest() {
        logger.debug("doing common test");
    }
}
