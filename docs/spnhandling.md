# Service Principal Handling (Database vs Key Vault)

___
[<< Contents](/procfwk/contents) 

___

## Azure Key Vault Roles

![Key Vault Icon](/procfwk/keyvault.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}Before detailing the different approaches within this code project for handling service principal values its important to define how the processing frameworking can optionally use Azure Key Vault. Specifically Key Vault can be used for the following two reasons:

1. Handling credentials used by [Data Factory](/procfwk/datafactory) to authenticate against the [SQL database](/procfwk/database) and [Functions Apps](/procfwk/functions) required by the processing framework for normal operations. This is done as part of the [Linked Service](/procfwk/linkedservices) connections.

2. Storing the service principal credentials (Application Id and Secret) required to interact with a given worker [pipeline(s)](/procfwk/pipeline) and target Data Factory instance.

The following content within this page only focuses on the second use case (role) for Azure Key Vault within the context of the processing framework and calling worker pipelines.

___

## Worker Authentication 

The processing framework supports the ability to use a different set of credentials for the execution of every single worker pipeline. This also includes the ability to call worker pipelines in different [tenants and subscriptions](/procfwk/crosstenantexecution), as well as different Data Factory instances. 

To make this possible each Azure [Function](/procfwk/functions) used within the framework execution is given a set of service principal (SPN) details at runtime and is responsbile for instantiating and authenticating with its own Data Factory client [helper](/procfwk/helpers). Once the management client connection is made using the .Net SDK the pipeline classes/methods are called to interact with the worker pipelines.

Given this understanding in the orchestration pipelines, the authentication details required by a given worker pipeline are returned from the metadata database using the infant pipeline [activities](/procfwk/activities). In each case, the database [table](/procfwk/tables) [dbo].[ServicePrincipals] is used to store the SPN information and joined to the worker pipeline information via a link table.

Depending on the framework configuration the [dbo].[ServicePrincipals] will contain either:

* Encrypted sets of SPN details, stored in the database directly.
  * The Application Id available in clear text.
  * The Appliction Secret as a VARBINARY value.
* A set of Key Vault URL's where the SPN details can be returned from as Key Vault secrets.

The different methods of handling service principal (SPN) details within the processing framework is configured using the database [properties](/procfwk/properties) table. The property used is called __SPNHandlingMethod__ and can have one of the following values. These values corrospond 

### StoreInDatabase




[ ![](/procfwk/spn-in-database.png) ](/procfwk/spn-in-database.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 250px;"}


### StoreInKeyVault

[ ![](/procfwk/spn-in-keyvault.png) ](/procfwk/spn-in-keyvault.png){:style="float: right;margin-left: 15px;margin-bottom: 10px; width: 250px;"}The database provides authentication details to the Azure Functions. However, the App Id and App Secret are Key Vault URL's rather than the actual decryted values.

The function recongises a URL has been provided in the request body using the internal helper methods, instantiates its own Key Vault client authenticating using the Function App Managed Service Identity. Then queries Key Vault using the URL to return the secret value.

Once done the Data Factory client is established.

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