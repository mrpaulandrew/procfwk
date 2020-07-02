using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    class GivenNoPipelineParameters
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithEmptyTable("procfwk.CurrentExecution")
                .WithEmptyTable("procfwk.PipelineParameters")
                .WithoutSimulatedError()
                .WithFailureHandling("Simple"); ;
            await _helper.RunPipeline();
        }

        #region Integration tests

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        #endregion

        #region Functional tests

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper.InsertNewPipelineParameters();
            _helper?.TearDown();
        }
    }
}
