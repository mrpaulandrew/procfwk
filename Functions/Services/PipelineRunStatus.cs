using System.Collections.Generic;

namespace mrpaulandrew.azure.procfwk.Services
{
    public class PipelineRunStatus
    {
        public string PipelineName { get; set; }
        public string RunId { get; set; }

        public string SimpleStatus { get; set; }
        public string ActualStatus { get; set; }
    }
}