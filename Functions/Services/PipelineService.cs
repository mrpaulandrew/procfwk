using mrpaulandrew.azure.procfwk.Helpers;
using Microsoft.Extensions.Logging;
using System;

namespace mrpaulandrew.azure.procfwk.Services
{
    public abstract class PipelineService : IDisposable
    {
        public const int internalWaitDuration = 5000; //ms

        public static PipelineService GetServiceForRequest(PipelineRequest pr, ILogger logger)
        {
            if (pr.OrchestratorType == PipelineServiceType.ADF)
                return new AzureDataFactoryService(pr, logger);

            if (pr.OrchestratorType == PipelineServiceType.SYN)
                return new AzureSynapseService(pr, logger);

            throw new InvalidRequestException ("Unsupported orchestrator type: " + (pr.OrchestratorType?.ToString() ?? "<null>"));
        }

        public abstract object ValidatePipeline(PipelineRequest request);

        public abstract PipelineRunStatus ExecutePipeline(PipelineRequest request);

        public abstract PipelineRunStatus CancelPipeline(PipelineRunRequest request);

        public abstract PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request);

        public abstract PipelineRunStatus GetPipelineRunActivityErrors(PipelineRunRequest request);

        public abstract void Dispose();
    }
}