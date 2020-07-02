using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Grandparent
{
    public class GivenOneWorkerPipeline
    {
        private GrandparentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new GrandparentHelper()
                .WithEmptyTable("procfwk.CurrentExecution")
                .WithSimpleFailureHandling()
                .WithOneWorkerPipelineEnabled();
            await _helper.RunPipeline();
        }

        #region Integration tests

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        #endregion
        
        [OneTimeTearDown]
        public void TearDown()
        {
            _helper.ResetParameterValue();
            _helper.EnableAllWorkerPipelines();
            _helper?.TearDown();
        }
    }
}
