using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenBatchExecutionsForConcurrentBatchesWithSimpleFailureHandlingAndRestartOveride
    {
        private ParentHelper _helperFirstBatch;
        private ParentHelper _helperSecondBatch;
        private ParentHelper _helperSecondBatchRestart;
        private ParentHelper _helperThirdBatch;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            //first
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

            //then
            _helperSecondBatchRestart = new ParentHelper()
                .WithoutSimulatedError()
                .WithOverideRestart(true)
                .WithParameter("BatchName", "Daily");

            _helperThirdBatch = new ParentHelper()
                .WithParameter("BatchName", "Hourly");

            var secondBatchRestart = _helperSecondBatchRestart.RunPipeline(10000); //10 second delay
            var thirdBatch = _helperThirdBatch.RunPipeline();

            await Task.WhenAll(secondBatchRestart, thirdBatch);
        }
        #region Integration tests

        //batch one - hourly:
        [Test]
        public void ThenFirstBatchPipelineOutcomeIsSucceeded()
        {
            _helperFirstBatch.RunOutcome.Should().Be("Succeeded");
        }

        //batch two - daily:
        [Test]
        public void ThenSecondBatchPipelineOutcomeIsFailed()
        {
            _helperSecondBatch.RunOutcome.Should().Be("Failed");
        }

        //batch two restart - daily:
        [Test]
        public void ThenSecondBatchRestartPipelineOutcomeIsSucceeded()
        {
            _helperSecondBatchRestart.RunOutcome.Should().Be("Succeeded");
        }

        //batch three - hourly:
        [Test]
        public void ThenThirdBatchPipelineOutcomeIsSucceeded()
        {
            _helperThirdBatch.RunOutcome.Should().Be("Succeeded");
        }
        #endregion

        #region Functional Tests
        [Test]
        public void ThenThreeBatchExecutionSuccessRecords()
        {
            _helperThirdBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Success").Should().Be(3);
        }

        [Test]
        public void ThenOneBatchExecutionAbandonedRecord()
        {
            _helperThirdBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Abandoned").Should().Be(1);
        }

        [Test]
        public void ThenTwentyTwoExecutionLogSuccessRecords()
        {
            _helperThirdBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(22);
        }

        [Test]
        public void ThenOneExecutionLogRecord()
        {
            _helperThirdBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Failed").Should().Be(2);
        }
        [Test]
        public void ThenSevenExecutionsBlocked()
        {
            _helperThirdBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Blocked").Should().Be(7);
        }
        [Test]
        public void ThenTwoErrorLogRecords()
        {
            _helperThirdBatch.RowCount("procfwk.ErrorLog").Should().Be(2);
        }

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helperThirdBatch.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperThirdBatch?.TearDown();
        }
    }
}
