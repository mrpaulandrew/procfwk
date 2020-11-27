using System.Collections.Generic;

namespace mrpaulandrew.azure.procfwk.Services
{
    public class PipelineRunStatus
    {
        public PipelineRunStatus()
        {
            Errors = new List<FailedActivity>();
        }

        public string PipelineName { get; set; }
        public string RunId { get; set; }

        public string SimpleStatus { get; set; }
        public string Status { get; set; }
        public string PipelineStatus { get { return Status; } set { Status = value; } }

        public int ResponseCount { get; set; }
        public int ResponseErrorCount
        {
            get
            {
                return Errors.Count;
            }
        }
        public List<FailedActivity> Errors { get; }
    }

    public class FailedActivity
    {
        public string ActivityRunId { get; internal set; }
        public string ActivityName { get; internal set; }
        public string ActivityType { get; internal set; }
        public string ErrorCode { get; internal set; }
        public string ErrorType { get; internal set; }
        public string ErrorMessage { get; internal set; }
    }
}