using Microsoft.Azure.Management.DataFactory.Models;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;

namespace FactoryTesting.Helpers
{
    public class PipelineRunHelper<T> : DataFactoryHelper<T> where T : PipelineRunHelper<T>
    {
        private readonly Dictionary<string, object> _parameters;
        private List<ActivityRun> _activityRuns;
        private bool _hasRun;

        public string RunId { get; private set; }

        public string RunOutcome { get; private set; }

        public PipelineRunHelper()
        {
            RunId = "Unknown";
            RunOutcome = "Unknown";
            _hasRun = false;
            _parameters = new Dictionary<string, object>();
        }

        public T WithParameter(string name, object value)
        {
            _parameters[name] = value;
            return (T)this;
        }

        public async Task RunPipeline(string pipelineName)
        {
            if (_hasRun)
                throw new Exception("RunPipeline() can only be called once per instance lifetime");
            _hasRun = true;

            RunId = await TriggerPipeline(pipelineName, _parameters);
            while (await IsInProgress(RunId))
                Thread.Sleep(2000);
            RunOutcome = await GetRunStatus(RunId);
        }

        public async Task<IEnumerable<ActivityRun>> GetActivityRuns()
        {
            await InitialiseActivityRuns();
            return _activityRuns;
        }

        public async Task<int> GetActivityRunCount(string pattern = ".*")
        {
            await InitialiseActivityRuns();
            Regex rgx = new Regex(pattern);
            return _activityRuns.Where(ar => rgx.IsMatch(ar.ActivityName)).Count();
        }

        private async Task InitialiseActivityRuns()
        {
            if (_activityRuns == null)
                _activityRuns = await GetActivityRuns(RunId);
        }

        public async Task<string> GetActivityOutput(string activityName, string propertyPath = "$")
        {
            await InitialiseActivityRuns();
            string output = _activityRuns.Where(ar => ar.ActivityName == activityName).FirstOrDefault().Output.ToString();
            var obj = JObject.Parse(output);
            return obj.SelectToken(propertyPath).ToString();
        }
    }
}
