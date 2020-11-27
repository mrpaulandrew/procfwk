using mrpaulandrew.azure.procfwk.Helpers;
using Microsoft.Extensions.Logging;
using System;

namespace mrpaulandrew.azure.procfwk.Services
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

        public abstract PipelineRunStatus CancelPipeline(PipelineRunRequest request);

        public abstract PipelineRunStatus GetPipelineRunStatus(PipelineRunRequest request);

        public abstract PipelineRunStatus GetPipelineRunActivityErrors(PipelineRunRequest request);

        public string ConvertPipelineStatus(string actualStatus)
        {
            string simpleStatus;

            //Create simple status for pipeline Until comparison checks
            switch (actualStatus)
            {
                case "Queued":
                    simpleStatus = "Running";
                    break;
                case "InProgress":
                    simpleStatus = "Running";
                    break;
                case "Canceling": //microsoft typo
                    simpleStatus = "Running";
                    break;
                case "Cancelling":
                    simpleStatus = "Running";
                    break;
                default:
                    simpleStatus = "Done";
                    break;
            }
            return simpleStatus;
        }

        public abstract void Dispose();
    }
}