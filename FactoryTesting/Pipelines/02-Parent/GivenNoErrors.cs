using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenNoErrors
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithEmptyTable("procfwk.CurrentExecution")
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

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helper.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
