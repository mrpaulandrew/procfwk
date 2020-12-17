using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenBatchExecutionsForConcurrentBatchesAlreadyRunning
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
                .WithParameter("BatchName", "Hourly");

            var firstBatch = _helperFirstBatch.RunPipeline();
            var secondBatch = _helperSecondBatch.RunPipeline(15000); //15 second delay in run

            await Task.WhenAll(firstBatch, secondBatch);
        }
        #region Integration tests

        [Test]
        public void ThenFirstBatchPipelineOutcomeIsSucceeded()
        {
            _helperFirstBatch.RunOutcome.Should().Be("Succeeded");
        }
        
        [Test]
        public void ThenSecondBatchPipelineOutcomeIsFailed()
        {
            _helperSecondBatch.RunOutcome.Should().Be("Failed");
        }

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helperFirstBatch.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        [Test]
        public void ThenFourExecutionLogSuccessRecords()
        {
            _helperFirstBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(4);
        }

        [Test]
        public void ThenOneBatchExecutionSuccessRecord()
        {
            _helperFirstBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Success").Should().Be(1);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperFirstBatch?.TearDown();
        }
    }
}
