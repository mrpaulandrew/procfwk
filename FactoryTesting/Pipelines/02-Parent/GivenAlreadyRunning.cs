using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenAlreadyRunning
    {
        private ParentHelper _helperRunOne;
        private ParentHelper _helperRunTwo;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helperRunOne = new ParentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .WithSPNInDatabase("FrameworkFactory")
                .WithEmptyExecutionTables()
                .WithoutSimulatedError()
                .WithFailureHandling("Simple");

            _helperRunTwo = new ParentHelper();

            var firstRun = _helperRunOne.RunPipeline();
            var secondRun = _helperRunTwo.RunPipeline(15000); //15 second delay in run

            await Task.WhenAll(firstRun, secondRun);
        }

        [Test]
        public void ThenFirstPipelineOutcomeIsSucceeded()
        {
            _helperRunOne.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void ThenSecondPipelineOutcomeIsFailed()
        {
            _helperRunTwo.RunOutcome.Should().Be("Failed");
        }

        [Test]
        public void ThenCurrentExecutionTableIsEmpty()
        {
            _helperRunOne.RowCount("procfwk.CurrentExecution").Should().Be(0);
        }

        [Test]
        public void ThenElevenExecutionLogRecords()
        {
            _helperRunOne.RowCount("procfwk.ExecutionLog").Should().Be(11);
        }

        [OneTimeTearDown]
        public void TearDown()
        {
            _helperRunOne?.TearDown();
        }
    }
}
