using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class GivenCancelledWorker
    {
        private ParentHelper _helper;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            _helper = new ParentHelper()
                .WithEmptyTable("procfwk.CurrentExecution")
                .WithEmptyTable("procfwk.ExecutionLog")
                .WithEmptyTable("procfwk.ErrorLog")
                .WithFailureHandling("Simple");
             //   .WithOnlyStageOneEnabled()
            //    .WithLongRunningWorkers();   
            await _helper.RunPipeline();
         /*
            Task task1 = Task.Factory.StartNew(() => _helper.RunPipeline());
            Task task2 = Task.Factory.StartNew(() => _helper.CancelRunningPipeline(_helper.GetWorkerRunId()));

            Task.WaitAll(task1, task2);
         */
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
