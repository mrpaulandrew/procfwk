using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenSimpleFailureHandling
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
                .WithSimulatedError()
                .WithFailureHandling("Simple");
            await _helper.RunPipeline();
        }

        #region Functional tests

        [Test, Order(1)]
        public void ThenPipelineOutcomeIsFailed()
        {
            _helper.RunOutcome.Should().Be("Failed");
        }
        
        [Test, Order(2)]
        public void ThenThreeExecutionsSucceeded()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Success").Should().Be(3);
        }
       
        [Test, Order(3)]
        public void ThenOneExecutionFailed()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Failed").Should().Be(1);
        }

        [Test, Order(4)]
        public void ThenSevenExecutionsBlocked()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Blocked").Should().Be(7);
        }

        [Test, Order(5)]
        public void ThenOneExecutionLogRecord()
        {
            _helper.RowCount("procfwk.ExecutionLog", where: "PipelineStatus", equals: "Failed").Should().Be(1);
        }
        
        [Test, Order(6)]
        public void ThenTwoErrorLogRecords()
        {
            _helper.RowCount("procfwk.ErrorLog").Should().Be(2);
        }
        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
