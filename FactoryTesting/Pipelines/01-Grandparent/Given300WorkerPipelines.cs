using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Grandparent
{
    public class Given300WorkerPipelines
    {
        private GrandparentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new GrandparentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .With300WorkerPipelinesEnabled()
                .WithSPNInKeyVault("WorkersFactory");

            await _helper.RunPipeline();
        }

        #region Integration tests

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
        public void Then300ExecutionLogRecords()
        {
            _helper.RowCount("procfwk.ExecutionLog").Should().Be(300);
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
