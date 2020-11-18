using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenThrowException
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithParameter("Message","NUnit Test");
            
            await _helper.RunPipeline("Throw Exception");
        }

        [Test]
        public void ThenPipelineOutcomeIsFailed()
        {
            _helper.RunOutcome.Should().Be("Failed");
        }
    }
}
