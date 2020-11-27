using Microsoft.Extensions.Logging;

namespace ADFprocfwk.Helpers
{
    public class PipelineRunRequest : PipelineRequest
    {
        public string RunId { get; set; }

        public override void Validate(ILogger logger)
        {
            base.Validate(logger);

            if (RunId == null)
                ReportInvalidBody(logger);
        }
    }
}
