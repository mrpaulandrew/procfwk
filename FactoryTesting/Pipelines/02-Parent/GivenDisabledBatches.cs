using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenDisabledBatches
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
                .WithBatchesDisabled();
            await _helper.RunPipeline();
        }

        #region Integration tests

        [Test]
        public void ThenPipelineOutcomeIsFailed()
        {
            _helper.RunOutcome.Should().Be("Failed");
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
