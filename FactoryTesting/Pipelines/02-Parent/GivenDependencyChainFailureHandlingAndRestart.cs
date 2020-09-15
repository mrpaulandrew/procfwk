using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenDependencyChainFailureHandlingAndRestart
    {
        private ParentHelper _helperFirstRun;
        private ParentHelper _helperRestartRun;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helperFirstRun = new ParentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .WithSPNInDatabase("FrameworkFactory")
                .WithEmptyExecutionTables()
                .WithSimulatedError()
                .WithFailureHandling("DependencyChain");
            await _helperFirstRun.RunPipeline();

            _helperRestartRun = new ParentHelper()
                .WithoutSimulatedError();
            await _helperRestartRun.RunPipeline();
        }

        #region Functional tests

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helperRestartRun.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenOneExecutionLogFailedRecord()
        {
            _helperRestartRun.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Failed").Should().Be(1);
        }
        [Test]
        public void ThenElevenExecutionLogSuccessRecord()
        {
            _helperRestartRun.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(11);
        }

        [Test]
        public void ThenTwoErrorLogRecords()
        {
            _helperRestartRun.RowCount("procfwk.ErrorLog").Should().Be(2);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperFirstRun?.TearDown();
        }
    }
}
