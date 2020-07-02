using FactoryTesting.Helpers;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Grandparent
{
    class GrandparentHelper : CoverageHelper<GrandparentHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("01-Grandparent");
        }

        public GrandparentHelper WithSimpleFailureHandling()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Properties] SET [PropertyValue] = 'Simple' WHERE [PropertyName] = 'FailureHandling'");
            return this;
        }
        public GrandparentHelper WithOneWorkerPipelineEnabled()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Pipelines] SET [Enabled] = 0 WHERE [PipelineId] > 1");
            return this;
        }
        public GrandparentHelper ResetParameterValue()
        {
            ExecuteNonQuery("UPDATE [procfwk].[PipelineParameters] SET [ParameterValue] = 5 WHERE [PipelineId] = 1");
            return this;
        }
        public GrandparentHelper EnableAllWorkerPipelines()
        {
            ExecuteNonQuery("UPDATE [procfwk].[Pipelines] SET [Enabled] = 1");
            return this;
        }
    }
}
