using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Grandparent
{
    public class Given600WorkerPipelineConcurrentBatches
    {
        private GrandparentHelper _helperFirstBatch;
        private GrandparentHelper _helperSecondBatch;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helperFirstBatch = new GrandparentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .With300WorkerPipelinesEnabled()
                .WithBatchExecutionHandling()
                .With300WorkerPipelineBatches()
                .WithSPNInKeyVault("WorkersFactory")
                .WithParameter("BatchName", "0to300");

            _helperSecondBatch = new GrandparentHelper()
                .WithParameter("BatchName", "301to600");

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
        public void ThenTwoBatchExecutionSuccessRecords()
        {
            _helperFirstBatch.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Success").Should().Be(2);
        }

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helperFirstBatch.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        [Test]
        public void Then300ExecutionLogRecords()
        {
            _helperFirstBatch.RowCount("procfwk.ExecutionLog").Should().Be(600);
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperFirstBatch?.TearDown();
        }
    }
}
