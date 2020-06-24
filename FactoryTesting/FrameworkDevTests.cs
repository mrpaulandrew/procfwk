using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting
{
    public class FrameworkDevTests
    {
        private Helpers testHelper;
        private string cachedRunId;

        [SetUp]
        public void WhenFrameworkRunIsCreated()
        {
            testHelper = new Helpers
            {
                ResourceGroupName = "ADF.procfwk",
                FactoryName = "FrameworkFactoryDev",
                PipelineName = "02-Parent"
            };
        }

        [Test]
        public async Task ThenPipelineOutcomeIsInProgres()
        {
            await testHelper.StartPipelineRun();
            cachedRunId = testHelper.TestRunId;

            Assert.AreEqual("InProgress", testHelper.PipelineOutcome);            
        }

        [Test]
        public async Task ThenPipelineOutcomeIsSucceeded()
        {
            await testHelper.PipelineRunComplete(cachedRunId);

            Assert.AreEqual("Succeeded", testHelper.PipelineOutcome);
        }
    }
}