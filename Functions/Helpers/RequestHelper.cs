using System;
using System.Collections.Generic;
using System.Text;

namespace ADFprocfwk.Helpers
{
    internal class RequestHelper
    {
        public static bool CheckUri(string uriValue)
        {
            bool result = Uri.TryCreate(uriValue, UriKind.Absolute, out Uri uriResult)
                && (uriResult.Scheme == Uri.UriSchemeHttp || uriResult.Scheme == Uri.UriSchemeHttps);

            return result;
        }

        public static bool CheckGuid(string idValue)
        {
            bool result = Guid.TryParse(idValue, out Guid idResult);

            return result;
        }
    }
}
