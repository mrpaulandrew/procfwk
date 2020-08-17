using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenNoErrorsAndSPNStoredInDatabase
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithBasicMetadata()
                .WithSubscriptionId()
                .WithTenantId()
                .WithSPNInDatabase("FrameworkFactory")
                .WithEmptyExecutionTables()
                .WithoutSimulatedError()
                .WithFailureHandling("Simple");
            await _helper.RunPipeline();
        }

        #region Integration tests

        [Test, Order(1)]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        #endregion

        #region Functional tests

        [Test, Order(2)]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helper.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        [Test, Order(3)]
        public void ThenElevenExecutionLogRecords()
        {
            _helper.RowCount("procfwk.ExecutionLog").Should().Be(11);
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
