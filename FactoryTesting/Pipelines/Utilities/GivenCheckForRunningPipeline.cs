using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;
using FactoryTesting.Helpers;

namespace FactoryTesting.Pipelines.Utilities
{
    public class GivenCheckForRunningPipeline
    {
        private UtilitiesHelper _helper;
      
        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new UtilitiesHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .WithParameter("PipelineName", "Check For Running Pipeline");

            await _helper.RunPipeline("Check For Running Pipeline");
        }

        [Test]
        public void ThenPipelineOutcomeIsFailed()
        {
            _helper.RunOutcome.Should().Be("Failed");
        }

        [Test]
        public async Task ThenActivityShouldReturnOneFilteredItemCount()
        {
            var filteredCount = await _helper.GetActivityOutput("Filter Running Pipelines", "$.FilteredItemsCount");
            int.Parse(filteredCount).Should().Be(1);
        }

        [Test]
        public async Task ThenActivityShouldReturnMatchingSubscriptionId()
        {
            string subSetting = _helper.GetSetting("AZURE_SUBSCRIPTION_ID");

            var subscriptionId = await _helper.GetActivityOutput("Set Subscription Id", "$.value");
            subscriptionId.Should().Equals(subSetting.ToString());
        }

        [Test]
        public async Task ThenActivityShouldReturnMatchingResourceGroup()
        {
            string rgSsetting = _helper.GetSetting("DataFactoryResourceGroup");

            var resourceGroupName = await _helper.GetActivityOutput("Set Resource Group Name", "$.value");
            resourceGroupName.Should().Equals(rgSsetting.ToString());
        }

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
