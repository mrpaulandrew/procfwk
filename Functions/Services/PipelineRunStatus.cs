using System.Collections.Generic;

namespace mrpaulandrew.azure.procfwk.Services
{
    public class PipelineRunStatus
    {
        private const string Running = "Running";
        private const string Complete = "Complete";

        public string PipelineName { get; set; }
        public string RunId { get; set; }
        public string ActualStatus { get; set; }

        public string SimpleStatus 
        {
            get
            {
                return ConvertPipelineStatus(ActualStatus);
            }
        }

        private string ConvertPipelineStatus(string actualStatus)
        {
            string simpleStatus = actualStatus switch
            {
                "Queued" => Running,
                "InProgress" => Running,
                "Canceling" => Running, //microsoft typo
                "Cancelling" => Running,
                _ => Complete,
            };
            return simpleStatus;
        }
    }
}