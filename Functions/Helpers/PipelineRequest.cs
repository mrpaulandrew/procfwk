using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;

namespace ADFprocfwk.Helpers
{
    public class PipelineRequest
    {
        public string TenantId { get; set; }
        public string ApplicationId { get; set; }
        public string AuthenticationKey { get; set; }
        public string SubscriptionId { get; set; }
        public string ResourceGroup { get; set; }
        public string FactoryName { get; set; }
        public string PipelineName { get; set; }
        public PipelineServiceType? OrchestratorType { get; set; }
        public Dictionary<string, string> PipelineParameters;

        public virtual void Validate(ILogger logger)
        {
            // ensure properties not null
            if (
              OrchestratorType == null ||
              TenantId == null ||
              ApplicationId == null ||
              AuthenticationKey == null ||
              SubscriptionId == null ||
              ResourceGroup == null ||
              FactoryName == null ||
              PipelineName == null
            )
                ReportInvalidBody(logger);

            // resolve key vault values
            logger.LogInformation(CheckGuid(ApplicationId).ToString());

            if (!CheckGuid(ApplicationId) && CheckUri(ApplicationId))
            {
                logger.LogInformation("Getting applicationId from Key Vault");
                ApplicationId = KeyVaultClient.GetSecretFromUri(ApplicationId);
            }

            if (CheckUri(AuthenticationKey))
            {
                logger.LogInformation("Getting authenticationKey from Key Vault");
                AuthenticationKey = KeyVaultClient.GetSecretFromUri(AuthenticationKey);
            }
        }

        private bool CheckUri(string uriValue)
        {
            bool result = Uri.TryCreate(uriValue, UriKind.Absolute, out Uri uriResult)
                && (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps);

            return result;
        }

        private bool CheckGuid(string idValue)
        {
            bool result = Guid.TryParse(idValue, out _);

            return result;
        }

        protected void ReportInvalidBody(ILogger logger)
        {
            var msg = "Invalid body.";
            logger.LogInformation(msg);
            throw new InvalidRequestException(msg);
        }

        public Dictionary<string, object> ParametersAsObjects
        {
            get
            {
                if (PipelineParameters == null)
                    return null;
                var dictionary = new Dictionary<string, object>();
                foreach (var key in PipelineParameters.Keys)
                    dictionary.Add(key, PipelineParameters[key]);
                return dictionary;
            }
        }
    }
}