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

        public abstract PipelineDescription ValidatePipeline(PipelineRequest request);

        public abstract PipelineRunStatus ExecutePipeline(PipelineRequest request);

        public abstract PipelineRunStatus CancelPipeline(PipelineRunRequest request);

        public abstract PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request);

        public abstract PipelineErrorDetail GetPipelineRunActivityErrors(PipelineRunRequest request);

        protected void PipelineNameCheck(string requestName, string foundName)
        {
            if (requestName.ToUpper() != foundName.ToUpper())
            {
                throw new InvalidRequestException($"Pipeline name mismatch. Provided pipeline name does not match the provided Run Id. Expected name: {foundName}");
            }
        }

        public abstract void Dispose();
    }
}