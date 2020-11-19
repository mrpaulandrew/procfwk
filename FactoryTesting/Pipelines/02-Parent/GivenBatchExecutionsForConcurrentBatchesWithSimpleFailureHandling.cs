using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenBatchExecutionsForConcurrentBatchesWithSimpleFailureHandling
    {
        private ParentHelper _helperFirstBatch;
        private ParentHelper _helperSecondBatch;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helperFirstBatch = new ParentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .WithSPNInDatabase("FrameworkFactory")
                .WithEmptyExecutionTables()
                .WithBatchExecutionHandling()
                .WithStagesEnabled()
                .WithPipelinesEnabled()
                .WithParameter("BatchName", "Hourly");

            _helperSecondBatch = new ParentHelper()
                .WithSimulatedError()
                .WithFailureHandling("Simple")
                .WithParameter("BatchName", "Daily");

            var firstBatch = _helperFirstBatch.RunPipeline();
            var secondBatch = _helperSecondBatch.RunPipeline();

            await Task.WhenAll(firstBatch, secondBatch);
        }
        #region Integration tests

        //batch one - hourly:
        [Test]
        public void ThenFirstBatchPipelineOutcomeIsSucceeded()
        {
            _helperFirstBatch.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenOneBatchExecutionSuccessRecord()
        {
            _helperFirstBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Success").Should().Be(1);
        }

        [Test]
        public void ThenFourExecutionLogSuccessRecords()
        {
            _helperFirstBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(4);
        }

        //batch two - daily:
        [Test]
        public void ThenSecondBatchPipelineOutcomeIsFailed()
        {
            _helperSecondBatch.RunOutcome.Should().Be("Failed");
        }

        [Test]
        public void ThenOneBatchExecutionStoppedRecord()
        {
            _helperSecondBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Stopped").Should().Be(1);
        }

        [Test]
        public void ThenThreeExecutionsSucceeded()
        {
            _helperSecondBatch.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Success").Should().Be(3);
        }

        [Test]
        public void ThenOneExecutionFailed()
        {
            _helperSecondBatch.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Failed").Should().Be(1);
        }

        [Test]
        public void ThenSevenExecutionsBlocked()
        {
            _helperSecondBatch.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Blocked").Should().Be(7);
        }

        [Test]
        public void ThenOneExecutionLogRecord()
        {
            _helperSecondBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Failed").Should().Be(1);
        }

        [Test]
        public void ThenTwoErrorLogRecords()
        {
            _helperSecondBatch.RowCount("procfwk.ErrorLog").Should().Be(2);
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperFirstBatch?.TearDown();
        }
    }
}
