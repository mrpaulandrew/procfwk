using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenDependencyChainFailureHandling
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithEmptyTable("procfwk.CurrentExecution")
                .WithSimulatedError()
                .WithFailureHandling("DependencyChain");
            await _helper.RunPipeline();
        }

        #region Functional tests

        [Test]
        public void ThenPipelineOutcomeIsFailed()
        {
            _helper.RunOutcome.Should().Be("Failed");
        }

        [Test]
        public void ThenOneExecutionFailed()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Failed").Should().Be(1);
        }

        [Test]
        public void ThenSixExecutionsSucceeded()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Success").Should().Be(6);
        }

        [Test]
        public void ThenFourExecutionsBlocked()
        {
            _helper.RowCount("procfwk.CurrentExecution", where: "PipelineStatus", equals: "Blocked").Should().Be(4);
        }

        #endregion
    }
}
