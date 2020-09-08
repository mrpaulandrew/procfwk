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

        public void AddTenantId()
        {
            var parameters = new Dictionary<string, object>
            {
                ["@PropertyName"] = "TenantId",
                ["@PropertyValue"] = GetSetting("AZURE_TENANT_ID"),
                ["@Description"] = "Used to provide authentication throughout the framework execution."
            };
            ExecuteStoredProcedure("[procfwkHelpers].[AddProperty]", parameters);
        }

        public void AddSubscriptionId()
        {
            var parameters = new Dictionary<string, object>
            {
                ["@PropertyName"] = "SubscriptionId",
                ["@PropertyValue"] = GetSetting("AZURE_SUBSCRIPTION_ID"),
                ["@Description"] = "Used to provide authentication throughout the framework execution."
            };
            ExecuteStoredProcedure("[procfwkHelpers].[AddProperty]", parameters);
        }

        public void AddWorkerSPNStoredInDatabase(string workerFactoryName)
        {
            ExecuteNonQuery("UPDATE [procfwk].[Properties] SET [PropertyValue] = 'StoreInDatabase' WHERE [PropertyName] = 'SPNHandlingMethod';");

            var parameters = new Dictionary<string, object>
            {
                ["@DataFactory"] = workerFactoryName,
                ["@PrincipalIdValue"] = GetSetting("AZURE_CLIENT_ID"),
                ["@PrincipalSecretValue"] = GetSetting("AZURE_CLIENT_SECRET"),
                ["@PrincipalName"] = GetSetting("AZURE_CLIENT_NAME")
            };

            ExecuteStoredProcedure("[procfwkHelpers].[AddServicePrincipalWrapper]", parameters);
        }

        public void AddWorkerSPNStoredInKeyVault(string workerFactoryName)
        {
            ExecuteNonQuery("UPDATE [procfwk].[Properties] SET [PropertyValue] = 'StoreInKeyVault' WHERE [PropertyName] = 'SPNHandlingMethod';");

            var parameters = new Dictionary<string, object>
            {
                ["@DataFactory"] = workerFactoryName,
                ["@PrincipalIdValue"] = GetSetting("AZURE_CLIENT_ID_URL"),
                ["@PrincipalSecretValue"] = GetSetting("AZURE_CLIENT_SECRET_URL"),
                ["@PrincipalName"] = GetSetting("AZURE_CLIENT_NAME")
            };

            ExecuteStoredProcedure("[procfwkHelpers].[AddServicePrincipalWrapper]", parameters);
        }

        public void AddBasicMetadata()
        {
            ExecuteStoredProcedure("[procfwkTesting].[ResetMetadata]", null);
        }

        public override void TearDown()
        {
            ExecuteStoredProcedure("[procfwkTesting].[CleanUpMetadata]", null);

            _conn?.Dispose();
            base.TearDown();
        }
    }
}
