using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenCancelledWorkerAndRestart
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
                .WithoutPrecursorObject() //done to ensure 2min waits are used, not example precursor waits
                .With2MinWaitsOnWorkers() //to ensure the cancel call has enough time
                .WithCancelledWorkersBlock(true)
                .WithFailureHandling("Simple");

            var runOrchestrator = _helperFirstRun.RunPipeline();
            var cancelWorker = _helperFirstRun.CancelAnyWorkerPipeline();

            await Task.WhenAll(runOrchestrator, cancelWorker);

            _helperRestartRun = new ParentHelper();
            await _helperRestartRun.RunPipeline();
        }
        #region Integration tests

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helperRestartRun.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenOneExecutionLogRecord()
        {
            _helperRestartRun.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Cancelled").Should().Be(1);
        }
        [Test]
        public void ThenElevenExecutionsSucceeded()
        {
            _helperRestartRun.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(11);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperRestartRun?.TearDown();
        }
    }
}
