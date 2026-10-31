package co.luminositylabs.oss.testing.nio2;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.Assert;
import org.testng.annotations.Test;

/**
 * Experiment C Test Class - Used for testing JUnit-TestNG-Surefire-Failsafe
 */
public class ExperimentCTest {

    /** The static logger instance. */
    private static final Logger logger = LoggerFactory.getLogger(ExperimentCTest.class);

    @Test(groups = {"C", "1"}, dependsOnGroups = {"B"})
    public void test1() {
        logger.debug("doing test 1");
    }

    @Test(groups = {"C", "2"}, dependsOnGroups = {"B"})
    public void test2() {
        logger.debug("doing test 2");
    }

    @Test(groups = {"C", "3"}, dependsOnGroups = {"B"})
    public void test3() {
        logger.debug("doing test 3");
        // Assert.fail("failing on purpose");
    }

    @Test(dependsOnMethods = {"test3"})
    public void someOtherTest() {
        logger.debug("doing some other test");
    }

    @Test(dependsOnMethods = {"someOtherTest"})
    public void some3rdTest() {
        logger.debug("doing some other test");
    }

    @Test(dependsOnMethods = {"some3rdTest"})
    public void some4thTest() {
        logger.debug("doing some other test");
    }

    @Test(dependsOnMethods = {"co.luminositylabs.oss.testing.nio2.ExperimentBTest.commonTest"})
    public void someMethodDependentTest() {
        logger.debug("doing some other test");
    }
}
