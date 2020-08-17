using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    class GivenDisabledPipelines
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
                .WithPipelinesDisabled();
            await _helper.RunPipeline();
        }

        #region Integration tests

        [Test, Order(1)]
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
