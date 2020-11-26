using ADFprocfwk.Helpers;
using Microsoft.Extensions.Logging;
using System;

namespace ADFprocfwk.Services
{
    public abstract class PipelineService : IDisposable
    {
        public static PipelineService GetServiceForRequest(PipelineRequest pr, ILogger logger)
        {
            if (pr.OrchestratorType == PipelineServiceType.ADF)
                return new AzureDataFactoryService(pr, logger);

            throw new InvalidRequestException ("Unsupported orchestrator type: " + (pr.OrchestratorType?.ToString() ?? "<null>"));
        }

        public abstract object ValidatePipeline(PipelineRequest request);

        public abstract PipelineRunStatus ExecutePipeline(PipelineRequest request);

        public abstract PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request);

        public abstract PipelineRunStatus GetPipelineRunActivityErrors(PipelineRunRequest request);

        public abstract void Dispose();
    }
}