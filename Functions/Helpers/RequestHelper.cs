using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Text;

namespace procfwk.Helpers
{
    internal class RequestHelper
    {
        #region fields
        private readonly string rawRequest;
        private readonly dynamic requestData;
        private readonly string requestPurpose;

        private readonly bool tenantIdRequired;
        private readonly bool applicationIdRequired;
        private readonly bool authenticationKeyRequired;
        private readonly bool subscriptionIdRequired;
        private readonly bool resourceGroupNameRequired;
        private readonly bool orchestratorNameRequired;
        private readonly bool orchestratorTypeRequired;
        private readonly bool pipelineNameRequired;
        private readonly bool runIdRequired;
        #endregion

        #region constructor
        public RequestHelper(string purpose, string providedBody)
        {
            rawRequest = providedBody;
            requestData = JsonConvert.DeserializeObject(rawRequest);
            requestPurpose = purpose;

            tenantIdRequired = true;
            applicationIdRequired = true;
            authenticationKeyRequired = true;
            subscriptionIdRequired = true;
            resourceGroupNameRequired = true;
            orchestratorNameRequired = true;
            orchestratorTypeRequired = true;

            switch (requestPurpose)
            {
                case "ExecutePipeline":
                    pipelineNameRequired = true;
                    runIdRequired = false;
                    break;
                case "CheckPipelineStatus":
                    pipelineNameRequired = false;
                    runIdRequired = true;
                    break;
                case "CancelPipeline":
                    pipelineNameRequired = false;
                    runIdRequired = true;
                    break;
                case "GetActivityErrors":
                    pipelineNameRequired = false;
                    runIdRequired = true;
                    break;
                case "ValidatePipeline":
                    pipelineNameRequired = true;
                    runIdRequired = false;
                    break;
            }
            
            //Set TenantId
            if (tenantIdRequired)
            {
                TenantId = requestData?.tenantId;
                if (TenantId == null || !CheckGuid(TenantId)) InvalidBodyItem("TenantId");
            }

            //Set ApplicationId
            if (applicationIdRequired)
            {
                ApplicationId = requestData?.applicationId;
                if (ApplicationId == null) InvalidBodyItem("ApplicationId");

                if (!CheckGuid(ApplicationId) && CheckUri(ApplicationId))
                {
                    ApplicationId = KeyVaultClient.GetSecretFromUri(ApplicationId);
                }
            }

            //Set AuthenticationKey
            if (authenticationKeyRequired)
            {
                AuthenticationKey = requestData?.authenticationKey;
                if (AuthenticationKey == null) InvalidBodyItem("AuthenticationKey");

                if (!CheckGuid(AuthenticationKey) && CheckUri(AuthenticationKey))
                {
                    AuthenticationKey = KeyVaultClient.GetSecretFromUri(AuthenticationKey);
                }
            }

            //Set SubscriptionId
            if (subscriptionIdRequired)
            {
                SubscriptionId = requestData?.subscriptionId;
                if (SubscriptionId == null || !CheckGuid(SubscriptionId)) InvalidBodyItem("SubscriptionId");
            }

            //Set ResourceGroupName
            if (resourceGroupNameRequired)
            {
                ResourceGroupName = requestData?.resourceGroupName;
                if (ResourceGroupName == null) InvalidBodyItem("ResourceGroupName");
            }

            //Set OrchestratorName
            if (orchestratorNameRequired)
            {
                OrchestratorName = requestData?.orchestratorName;
                if (OrchestratorName == null) InvalidBodyItem("OrchestratorName");
            }

            //Set OrchestratorType
            if (orchestratorTypeRequired)
            {
                OrchestratorType = requestData?.orchestratorType;
                if (OrchestratorType == null) InvalidBodyItem("OrchestratorType");

                OrchestratorType = OrchestratorType.ToUpper();
                if (OrchestratorType != "ADF" && OrchestratorType != "SYN") InvalidOrchestratorType();
            }

            //Set Pipeline Name
            if (pipelineNameRequired)
            {
                PipelineName = requestData?.pipelineName;
                if (PipelineName == null) InvalidBodyItem("PipelineName");
            }
            else
            {
                PipelineName = requestData?.pipelineName ?? "Not provided";
            }

            //Set RunId
            if (runIdRequired)
            {
                RunId = requestData?.runId;
                if (RunId == null) InvalidBodyItem("RunId");
            }
            else
            {
                RunId = requestData?.runId ?? "Not provided";
            }

            //Set PipelineParameters
            if (requestData?.pipelineParameters != null)
            {
                PipelineParametersProvided = true;

                JObject jObj = JObject.Parse(rawRequest);
                PipelineParameters = jObj["pipelineParameters"].ToObject<Dictionary<string, object>>();
            }
            else
            {
                PipelineParametersProvided = false;
            }

            //Set Recursive Cancel
            if (requestData?.recursiveCancel != null)
            {
                bool.TryParse(requestData?.recursiveCancel.ToString(), out bool requestValue);

                RecursivePipelineCancel = requestValue;
            }
            else
            {
                RecursivePipelineCancel = true;
            }
        }
        #endregion

        #region properties
        public string TenantId { get; }

        public string ApplicationId { get; }

        public string AuthenticationKey { get; }

        public string SubscriptionId { get; }

        public string ResourceGroupName { get; }

        public string OrchestratorName { get; }

        public string OrchestratorType { get; }

        public string PipelineName { get; }

        public string RunId { get; }

        public bool PipelineParametersProvided { get; }

        public Dictionary<string, object> PipelineParameters { get; }

        public bool RecursivePipelineCancel { get; }
        #endregion

        public static bool CheckUri(string uriValue)
        {
            bool result = Uri.TryCreate(uriValue, UriKind.Absolute, out Uri uriResult)
                && (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps);

            return result;
        }

        public static bool CheckGuid(string guidValue)
        {
            bool result = Guid.TryParse(guidValue, out Guid guidResult);
            return result;
        }

        private static void InvalidBodyItem (string itemName)
        {
            Exception ex = new Exception($"Invalid body request. Value {itemName} cannot be null or is in the wrong format for the function called.");
            throw ex;
        }
        private static void InvalidOrchestratorType()
        {
            Exception ex = new Exception($"Invalid orchestartor type provided. Expected values: ADF or SYN.");
            throw ex;
        }
    }
}
