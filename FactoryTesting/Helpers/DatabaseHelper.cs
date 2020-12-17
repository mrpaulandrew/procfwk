using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace FactoryTesting.Helpers
{
    public class DatabaseHelper<T> : PipelineRunHelper<T> where T : DatabaseHelper<T>
    {
        public SqlConnection _conn;

        public DatabaseHelper()
        {
            _conn = new SqlConnection(GetSetting(GetSetting("MetadataDbConnectionStringSecretName")));
            _conn.Open();
        }

        public T WithEmptyTable(string tableName)
        {
            using (var cmd = new SqlCommand($"TRUNCATE TABLE {tableName}", _conn))
                cmd.ExecuteNonQuery();
            return (T)this;
        }

        public int RowCount(string tableName, string where = "", string equals = "")
        {
            using (var cmd = new SqlCommand($"SELECT COUNT(*) FROM {tableName}"
                + (where?.Length == 0 ? "" : $" WHERE {where} = '{equals.Replace("'", "''")}'")
                , _conn))
            using (var reader = cmd.ExecuteReader())
            {
                reader.Read();
                return reader.GetInt32(0);
            }
        }

        public string ColumnData(string tableName, string columnName, char separator = ',')
        {
            using (var cmd = new SqlCommand($"SELECT STRING_AGG([{columnName}],'{separator}') FROM {tableName}", _conn))
            using (var reader = cmd.ExecuteReader())
            {
                reader.Read();
                return reader.GetString(0);
            }
        }

        public void ExecuteStoredProcedure(string spName, Dictionary<string, object> parameters = null)
        {
            using (var cmd = new SqlCommand(spName, _conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                if (parameters != null)
                    foreach (string parameterName in parameters.Keys)
                        cmd.Parameters.Add(new SqlParameter(parameterName, parameters[parameterName]));
                cmd.ExecuteNonQuery();
            }
        }

        public void ExecuteNonQuery(string sql)
        {
            using (var cmd = new SqlCommand(sql, _conn))
                cmd.ExecuteNonQuery();
        }

        public void AddTenantAndSubscription(string tenantId = null, string subscriptionId = null)
        {
            if (string.IsNullOrEmpty(tenantId)) tenantId = GetSetting("AZURE_TENANT_ID");
            if (string.IsNullOrEmpty(subscriptionId)) subscriptionId = GetSetting("AZURE_SUBSCRIPTION_ID");

            ExecuteNonQuery($"INSERT INTO[procfwk].[Tenants] ([TenantId],[Name],[Description]) VALUES ('{tenantId}', 'mrpaulandrew.com', NULL);");
            ExecuteNonQuery($"INSERT INTO [procfwk].[Subscriptions] ([SubscriptionId],[Name],[Description],[TenantId]) VALUES ('{subscriptionId}', 'Microsoft Sponsored Subscription', NULL, '{tenantId}');");
            ExecuteNonQuery($"UPDATE [procfwk].[Orchestrators] SET [SubscriptionId] = '{subscriptionId}';");
        }

        public void AddWorkerSPNStoredInDatabase(string workerFactoryName, string orchestratorType = "ADF")
        {
            ExecuteNonQuery("UPDATE [procfwk].[Properties] SET [PropertyValue] = 'StoreInDatabase' WHERE [PropertyName] = 'SPNHandlingMethod';");

            var parameters = new Dictionary<string, object>
            {
                ["@OrchestratorName"] = workerFactoryName,
                ["@OrchestratorType"] = orchestratorType,
                ["@PrincipalIdValue"] = GetSetting("AZURE_CLIENT_ID"),
                ["@PrincipalSecretValue"] = GetSetting("AZURE_CLIENT_SECRET"),
                ["@PrincipalName"] = GetSetting("AZURE_CLIENT_NAME")
            };

            ExecuteStoredProcedure("[procfwkHelpers].[AddServicePrincipalWrapper]", parameters);
        }

        public void AddWorkerSPNStoredInKeyVault(string workerFactoryName, string orchestratorType = "ADF")
        {
            ExecuteNonQuery("UPDATE [procfwk].[Properties] SET [PropertyValue] = 'StoreInKeyVault' WHERE [PropertyName] = 'SPNHandlingMethod';");

            var parameters = new Dictionary<string, object>
            {
                ["@OrchestratorName"] = workerFactoryName,
                ["@OrchestratorType"] = orchestratorType,
                ["@PrincipalIdValue"] = GetSetting("AZURE_CLIENT_ID_URL"),
                ["@PrincipalSecretValue"] = GetSetting("AZURE_CLIENT_SECRET_URL"),
                ["@PrincipalName"] = GetSetting("AZURE_CLIENT_NAME")
            };

            ExecuteStoredProcedure("[procfwkHelpers].[AddServicePrincipalWrapper]", parameters);
        }

        public void AddBasicMetadata()
        {
            ExecuteStoredProcedure("[procfwkTesting].[ResetMetadata]", null);
            ExecuteNonQuery("UPDATE [procfwk].[Orchestrators] SET [IsFrameworkOrchestrator] = '0';");
            ExecuteNonQuery($"UPDATE [procfwk].[Orchestrators] SET [IsFrameworkOrchestrator] = '1' WHERE [OrchestratorName] = '{GetSetting("DataFactoryName")}';");
        }

        public override void TearDown()
        {
            ExecuteStoredProcedure("[procfwkTesting].[CleanUpMetadata]", null);

            _conn?.Dispose();
            base.TearDown();
        }
    }
}
