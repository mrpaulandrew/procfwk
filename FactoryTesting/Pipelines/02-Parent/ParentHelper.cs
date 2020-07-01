using FactoryTesting.Helpers;
using System.Threading.Tasks;

namespace FactoryTesting.Pipelines.Parent
{
    class ParentHelper : PipelineRunHelper<ParentHelper>
    {
        public async Task RunPipeline()
        {
            await RunPipeline("02-Parent");
        }
    }
}
