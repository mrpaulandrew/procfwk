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
                .With300WorkerPipelinesEnabled()
                .WithSubscriptionId()
                .WithTenantId()
                .WithSPNInKeyVault("WorkersFactory");

            await _helper.RunPipeline();
        }

        #region Integration tests

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        #endregion

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
