using System;
using Microsoft.Extensions.Logging;

namespace mrpaulandrew.azure.procfwk.Helpers
{
    public class PipelineRunRequest : PipelineRequest
    {
        public string RunId { get; set; }

        public bool RecursivePipelineCancel = true; //might provide this as part of the request later

        public DateTime ActivityQueryStart = DateTime.Now.AddDays(-7); //max duration for eventual RunFilterParameters
        public DateTime ActivityQueryEnd = DateTime.Now;

        public override void Validate(ILogger logger)
        {
            base.Validate(logger);

            // ensure properties not null
            if (RunId == null)
                ReportInvalidBody(logger);

            //other validation
            if (!CheckGuid(RunId)) ReportInvalidBody(logger, "Expected Run Id to be a GUID.");
        }
    }
}
