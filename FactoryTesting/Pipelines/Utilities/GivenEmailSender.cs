using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Utilities
{
    public class GivenEmailSender
    {
        private UtilitiesHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new UtilitiesHelper()
                .WithParameter("Recipients", "paul@mrpaulandrew.com")
                .WithParameter("Subject", "NUnit Test")
                .WithParameter("Body", "NUnit Test"); ;

            await _helper.RunPipeline("Email Sender");
        }

        [Test]
        public void ThenPipelineOutcomeIsSucceeded()
        {
            _helper.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public async Task ThenActivityShouldReturnEmailSentTrue()
        {
            var sentState = await _helper.GetActivityOutput("Send Email", "$.EmailSent");
            bool.Parse(sentState).Should().Be(true);
        }

        [OneTimeTearDown]
        public void TearDown()
        {
            _helper?.TearDown();
        }
    }
}
