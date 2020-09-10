## SPN Handling (Database vs Key Vault)

___
[<< Contents](/ADF.procfwk/contents) 

___

Way back in v1.1 of the processing framework I added SPN details to the database metadata. This was and still is to enable the Azure Functions to authenticate against Data Factory when executing, checking and returning error information for our Worker pipelines. 

Storing these SPN values in a database table (even though encrypted) never really felt great, but at the time it was the best option. Reflecting again on the original design and considering the credential have to be stored somewhere to offer us the flexibility to hit and authenticate against any Data Factory in the subscription and allowing the use of different SPN's for different pipelines, this was the right choice. 

As a refresher, the following visual from the v1.1 release demonstrates the SPN values being retrieved from the metadata and passed to the Functions via the request body. In addition to storing the values in the database in means that the client secret are also available to be view via the Data Factory monitoring screens if you dig into the activity input values. So, again, this doesn't feel great.

![SPN Handling in Database](https://mrpaulandrew.files.wordpress.com/2020/07/procfwk-authenticate-with-spns.png)

Now, happily, we have a better option and one that only requires a subtle change to our metadata and still retains the flexible setup of Data Factory's vs Pipelines vs SPN's.

The key to this new capability is that Azure Function App's now support Managed Service Identities (MSI). This means a Function App can authenticate itself via an access policy in Azure Key Vault. Then SPN values can be retrieved as secrets from Key Vault as part of the Function execution. Microsoft docs link:

[https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity)

To clarify, previously, I didn't do this because without the MSI support the Function would still of needed its own SPN credentials to first authenticate against Key Vault before returning the SPN credentials for Data Factory. In this case, the "starting point" SPN had to be stored somewhere, so at the time I choose the database.

Given the above, what we can now do, instead of storing the actual SPN details in the database. Just store the Key Vault URL's in the database that offer an address to the actual SPN details. Then via its own MSI ask the Function to get the details from Key Vault using the URLs.

The authentication flow if you choose this option would then have the extra step of the Function hitting Key Vault as well as runtime to resolve the secret URL to an actual value. Rather than having the actual value already from the database.

![SPN Handling with Key Vault](https://mrpaulandrew.files.wordpress.com/2020/07/procfwk-authenticate-with-urls-1.png)

As mentioned, hopefully this is a fairly subtle change and an easy one to implement. By default, the previous SPN handling behaviour will remain unchanged. This is another completely optional feature. Please also be aware, no changes are required in Data Factory to implement this option. Data Factory doesn't care if its passing the SPN Id to the Function activities or the Key Vault URL for the SPN Id.

Final thought here, before going into the development detail, it would be even nicer to take this one step further and just use the Function MSI to authenticate against Data Factory directly. However, this isn't currently supported and would also reduce the flexibility in the metadata allowing different SPN's for different pipelines. Therefore, SPN values still need to be passed around for now to authenticate against ADF.