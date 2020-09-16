using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenCancelledWorkerThatBlocks
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .WithSPNInDatabase("FrameworkFactory")
                .WithEmptyExecutionTables()
                .WithoutPrecursorObject() //done to ensure 2min waits are used, not example precursor waits
                .With2MinWaitsOnWorkers() //to ensure the cancel call has enough time
                .WithCancelledWorkersBlock(true)
                .WithFailureHandling("Simple");

            var runOrchestrator = _helper.RunPipeline();
            var cancelWorker = _helper.CancelIntentionalErrorWorkerPipeline(); //specific worker

            await Task.WhenAll(runOrchestrator, cancelWorker);
        }
        #region Integration tests

        [Test]
        public void ThenPipelineOutcomeIsFailed()
        {
            _helper.RunOutcome.Should().Be("Failed");
        }

        [Test]
        public void ThenOneExecutionsCancelled()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Cancelled").Should().Be(1);
        }

        [Test]
        public void ThenOneExecutionLogRecord()
        {
            _helper.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Cancelled").Should().Be(1);
        }
        [Test]
        public void ThenThreeExecutionsSucceeded()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Success").Should().Be(3);
        }
        [Test]
        public void ThenSevenExecutionsBlocked()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Blocked").Should().Be(7);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
