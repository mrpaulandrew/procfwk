using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace FactoryTesting.Helpers
{
    public class DatabaseHelper<T> : PipelineRunHelper<T> where T : DatabaseHelper<T>
    {
        private SqlConnection _conn;

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

        public override void TearDown()
        {
            using (var cmd = new SqlCommand($"TRUNCATE TABLE [procfwk].[CurrentExecution]", _conn))
                cmd.ExecuteNonQuery();

            _conn?.Dispose();
            base.TearDown();
        }
    }
}
