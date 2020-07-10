using FactoryTesting.Helpers;
using Microsoft.Azure.Management.DataFactory.Models;
using NUnit.Framework;
using System;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace FactoryTesting.Helpers
{
    public class CoverageHelper<T> : DatabaseHelper<T> where T : CoverageHelper<T>
    {
        public new async Task RunPipeline(string pipelineName)
        {
            var callStack = new System.Diagnostics.StackTrace();
            await base.RunPipeline(pipelineName);
            if (ReportTestCoverage)
                foreach (var ar in await GetActivityRuns())
                    RecordActivityRun(ar, callStack.ToString());
        }

        public bool ReportTestCoverage
        {
            get
            {
                try
                {
                    var measure = GetSetting("ReportTestCoverage");
                    if (measure == "true")
                        return true;
                }
                catch (Exception) { }
                return false;
            }
        }

        private void RecordActivityRun(ActivityRun ar, string context)
        {
            var parameters = new Dictionary<string, object>
            {
                ["@pipelineName"] = ar.PipelineName,
                ["@activityName"] = ar.ActivityName,
                ["@context"] = context
            };
            ExecuteStoredProcedure("test.RecordActivityRun", parameters);
        }
    }
}

[SetUpFixture]
public class CoverageHelperSetup : CoverageHelper<CoverageHelperSetup>
{
    [OneTimeSetUp]
    public async Task SetupCoverageHelper()
    {
        if (ReportTestCoverage)
        {
            WithEmptyTable("test.ActivityRun");
            WithEmptyTable("test.PipelineActivity");

            foreach (var p in await GetPipelines())
                if (p.Activities != null)
                    foreach (var a in p.Activities)
                        RecordActivity(p.Name, a);
        }

        TearDown();
    }

    private void RecordActivity(string pipelineName, Activity act)
    {
        var parameters = new Dictionary<string, object>
        {
            ["@pipelineName"] = pipelineName,
            ["@activityName"] = act.Name
        };
        ExecuteStoredProcedure("test.RecordActivity", parameters);

        if (act is ForEachActivity)
            foreach (var a in ((ForEachActivity)act).Activities)
                RecordActivity(pipelineName, a);

        if (act is UntilActivity)
            foreach (var a in ((UntilActivity)act).Activities)
                RecordActivity(pipelineName, a);

        if (act is IfConditionActivity)
        {
            foreach (var a in ((IfConditionActivity)act).IfTrueActivities)
                RecordActivity(pipelineName, a);
            foreach (var a in ((IfConditionActivity)act).IfFalseActivities)
                RecordActivity(pipelineName, a);
        }

        if (act is SwitchActivity)
            foreach (var c in ((SwitchActivity)act).Cases)
                foreach (var a in c.Activities)
                    RecordActivity(pipelineName, a);
    }
}
