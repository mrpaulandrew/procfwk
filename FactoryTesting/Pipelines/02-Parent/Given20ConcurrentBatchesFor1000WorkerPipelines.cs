using FluentAssertions;
using NUnit.Framework;
using NUnit.Framework.Internal;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    public class Given20ConcurrentBatchesFor1000WorkerPipelines
    {
        private ParentHelper _helperBatchOne;
        private ParentHelper _helperBatchTwo;
        private ParentHelper _helperBatchEleven;
        private ParentHelper _helperBatchTwelve;
        private ParentHelper _helperBatchTwenty;
        private ParentHelper _helperBatchFifteen;
        private ParentHelper _helperBatchSeven;
        private ParentHelper _helperBatchNine;
        private ParentHelper _helperBatchEight;
        private ParentHelper _helperBatchSixteen;
        private ParentHelper _helperBatchFive;
        private ParentHelper _helperBatchSix;
        private ParentHelper _helperBatchThirteen;
        private ParentHelper _helperBatchNineteen;
        private ParentHelper _helperBatchFour;
        private ParentHelper _helperBatchEighteen;
        private ParentHelper _helperBatchThree;
        private ParentHelper _helperBatchFourteen;
        private ParentHelper _helperBatchTen;
        private ParentHelper _helperBatchSeventeen;

        [OneTimeSetUp]
        public async Task WhenPipelineRun()
        {
            /*
            _helperBatchOne = new ParentHelper()
                .WithBasicMetadata()
                .WithTenantAndSubscriptionIds()
                .WithBatchExecutionHandling()
                .With20BatchesFor1000WorkersEnabled()
                .WithSPNInKeyVault("WorkersFactory")
                .WithParameter("BatchName", "One");
            */
            _helperBatchOne = new ParentHelper()
                .WithCustom()
                .WithParameter("BatchName", "One");
            
            _helperBatchTwo = new ParentHelper().WithParameter("BatchName", "Two");
            _helperBatchEleven = new ParentHelper().WithParameter("BatchName", "Eleven");
            _helperBatchTwelve = new ParentHelper().WithParameter("BatchName", "Twelve");
            _helperBatchTwenty = new ParentHelper().WithParameter("BatchName", "Twenty");
            _helperBatchFifteen = new ParentHelper().WithParameter("BatchName", "Fifteen");
            _helperBatchSeven = new ParentHelper().WithParameter("BatchName", "Seven");
            _helperBatchNine = new ParentHelper().WithParameter("BatchName", "Nine");
            _helperBatchEight = new ParentHelper().WithParameter("BatchName", "Eight");
            _helperBatchSixteen = new ParentHelper().WithParameter("BatchName", "Sixteen");
            _helperBatchFive = new ParentHelper().WithParameter("BatchName", "Five");
            _helperBatchSix = new ParentHelper().WithParameter("BatchName", "Six");
            _helperBatchThirteen = new ParentHelper().WithParameter("BatchName", "Thirteen");
            _helperBatchNineteen = new ParentHelper().WithParameter("BatchName", "Nineteen");
            _helperBatchFour = new ParentHelper().WithParameter("BatchName", "Four");
            _helperBatchEighteen = new ParentHelper().WithParameter("BatchName", "Eighteen");
            _helperBatchThree = new ParentHelper().WithParameter("BatchName", "Three");
            _helperBatchFourteen = new ParentHelper().WithParameter("BatchName", "Fourteen");
            _helperBatchTen = new ParentHelper().WithParameter("BatchName", "Ten");
            _helperBatchSeventeen = new ParentHelper().WithParameter("BatchName", "Seventeen");
            
            var batchOne = _helperBatchOne.RunPipeline();
            var batchTwo = _helperBatchTwo.RunPipeline();
            var batchEleven = _helperBatchEleven.RunPipeline();
            var batchTwelve = _helperBatchTwelve.RunPipeline();
            var batchTwenty = _helperBatchTwenty.RunPipeline();
            var batchFifteen = _helperBatchFifteen.RunPipeline();
            var batchSeven = _helperBatchSeven.RunPipeline();
            var batchNine = _helperBatchNine.RunPipeline();
            var batchEight = _helperBatchEight.RunPipeline();
            var batchSixteen = _helperBatchSixteen.RunPipeline();
            var batchFive = _helperBatchFive.RunPipeline();
            var batchSix = _helperBatchSix.RunPipeline();
            var batchThirteen = _helperBatchThirteen.RunPipeline();
            var batchNineteen = _helperBatchNineteen.RunPipeline();
            var batchFour = _helperBatchFour.RunPipeline();
            var batchEighteen = _helperBatchEighteen.RunPipeline();
            var batchThree = _helperBatchThree.RunPipeline();
            var batchFourteen = _helperBatchFourteen.RunPipeline();
            var batchTen = _helperBatchTen.RunPipeline();
            var batchSeventeen = _helperBatchSeventeen.RunPipeline();
            
            //await _helperBatchOne.RunPipeline();
            
            await Task.WhenAll(
                                batchOne,
                                batchTwo,
                                batchEleven,
                                batchTwelve,
                                batchTwenty,
                                batchFifteen,
                                batchSeven,
                                batchNine,
                                batchEight,
                                batchSixteen,
                                batchFive,
                                batchSix,
                                batchThirteen,
                                batchNineteen,
                                batchFour,
                                batchEighteen,
                                batchThree,
                                batchFourteen,
                                batchTen,
                                batchSeventeen
                            );
        }

        #region Integration tests

        [Test]
        public void ThenOneBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchOne.RunOutcome.Should().Be("Succeeded");
        }
        
        [Test]
        public void ThenTwoBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchTwo.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenElevenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchEleven.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenTwelveBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchTwelve.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenTwentyBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchTwenty.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenFifteenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchFifteen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenSevenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchSeven.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenNineBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchNine.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenEightBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchEight.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenSixteenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchSixteen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenFiveBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchFive.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenSixBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchSix.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenThirteenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchThirteen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenNineteenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchNineteen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenFourBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchFour.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenEighteenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchEighteen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenThreeBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchThree.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenFourteenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchFourteen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenTenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchTen.RunOutcome.Should().Be("Succeeded");
        }
        [Test]
        public void ThenSeventeenBatchPipelineOutcomeIsSucceeded()
        {
            _helperBatchSeventeen.RunOutcome.Should().Be("Succeeded");
        }

        [Test]
        public void Then1000ExecutionLogRecords()
        {
            _helperBatchOne.RowCount("procfwk.ExecutionLog").Should().Be(1000);
        }
        
        #endregion
        /*
        [OneTimeTearDown]
        public void TearDown()
        {
            _helperBatchOne?.TearDown();
        }
        */
    }
}
