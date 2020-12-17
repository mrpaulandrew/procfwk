using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenBatchExecutionsForConcurrentBatches
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
                .WithParameter("BatchName", "Daily");

            var firstBatch = _helperFirstBatch.RunPipeline();
            var secondBatch = _helperSecondBatch.RunPipeline();

            await Task.WhenAll(firstBatch, secondBatch);
        }
        #region Integration tests

        [Test]
        public void ThenFirstBatchPipelineOutcomeIsSucceeded()
        {
            _helperFirstBatch.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenSecondBatchPipelineOutcomeIsSucceeded()
        {
            _helperSecondBatch.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helperFirstBatch.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        [Test]
        public void ThenFifteenExecutionLogSuccessRecords()
        {
            _helperFirstBatch.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(15);
        }

        [Test]
        public void ThenTwoBatchExecutionSuccessRecords()
        {
            _helperFirstBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Success").Should().Be(2);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperFirstBatch?.TearDown();
        }
    }
}
