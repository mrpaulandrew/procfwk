using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenBatchExecutionsForSingleBatch
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
                .WithBatchExecutionHandling()
                .WithStagesEnabled()
                .WithPipelinesEnabled()
                .WithParameter("BatchName", "Hourly");
            await _helper.RunPipeline();
        }

        #region Functional tests

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helper.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        [Test]
        public void ThenFourExecutionLogSuccessRecords()
        {
            _helper.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Success").Should().Be(4);
        }

        [Test]
        public void ThenOneBatchExecutionSuccessRecord()
        {
            _helper.RowCount("procfwk.BatchExecution", where: "BatchStatus", equals: "Success").Should().Be(1);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
