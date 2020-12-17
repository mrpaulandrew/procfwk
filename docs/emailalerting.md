# Email Alerting

___
[<< Contents](/procfwk/contents) 

___

Email alerting can be delivered within the processing framework and using existing metadata to drive behaviour offering easy control, flexible and granular ways to subscribe to the status of a given worker pipeline outcome. 

[ ![](/procfwk/iconwithalerting.png) ](/procfwk/iconwithalerting.png)

The following statements have been met in terms of alerting capabilities and design:

* Email alerting is a completely optional feature that can be turned on/off via the main database [properties](/procfwk/propertis) table.
* Recipient email addresses are stored as metadata within the framework [database](/procfwk/database).
* Recipients can be enabled/disabled as required.
* Recipients can subscribe to one or many worker [pipelines](/procfwk/pipelines) to receive alerts.
* Recipients can optionally be included in the email message as the main receiver (__To__), copied (__CC__) or blind copied (__BCC__).
* Pipeline alert subscriptions (links) can be enabled/disabled as required within the metadata [table](/procfwk/tables).
* Pipeline alert subscriptions (links) can be setup for all or one particular worker pipelines outcome using the pipeline result status from the current execution table. For example; Success, Failed, Cancelled etc.
* Alerting content can be customised using a generic email body configured in the [properties](/procfwk/propertis) that has the details like the [orchestrator](/procfwk/orchestrators) name/type and Pipeline name injected into the underlying HTML message at runtime.
* SMTP details are configured via the Azure Function 'SendEmail' application settings.
* Email traffic is reduced to only a single message sent per worker pipeline. Not one message per recipient.

## Enabling & Disabling Email Alerting

Using email alerting in as part of the processing framework is set by the [property](/procfwk/properties) __UseFrameworkEmailAlerting__.

As stated above, the alerting features of the framework are completely optional. You may already have a different way of producing alerts for your pipelines. If so, simply set this property value to '0' and alerting will be disabled for your processing framework.

## Adding & Removing Email Recipients

The following helper stored procedure can be used to add and remove email recipients from the metadata database tables.

* __[procfwk].[AddRecipientPipelineAlerts]__ - Assuming a recipient email address record has already been added this procedure creates the alert link between the recipient record and the Worker pipeline(s). Default parameters can be used to add the link for either a specific pipeline or all pipelines. Then either all pipeline status values or just a subset. A comma separated string can be used to translate the named values into the correct bitmask value.

	The following code snippets provide example of adding alerts for three different recipients for different worker pipelines and different combinations are outcomes.

```sql
EXEC [procfwkHelpers].[AddRecipientPipelineAlerts]
	@RecipientName = N'Test User 1',
	@AlertForStatus = 'All';

EXEC [procfwkHelpers].[AddRecipientPipelineAlerts]
	@RecipientName = N'Test User 2',
	@PipelineName = 'Intentional Error',
	@AlertForStatus = 'Failed';

EXEC [procfwkHelpers].[AddRecipientPipelineAlerts]
	@RecipientName = N'Test User 3',
	@PipelineName = 'Wait 1',
	@AlertForStatus = 'Success, Failed, Cancelled';	
```

* __[procfwk].[DeleteRecipientAlerts]__ - This procedure provides the opposite affect to the 'add' procedure above. It also supports soft deletions using the link table and recipients table 'Enabled' attributes to UPDATE them to '0' if a hard DELETE isn't yet required. Soft deletions are the default parameter behaviour when executing the procedure.

## Sending Emails

Once the metadata has been returned from the [database](/procfwk/database) to the [orchestrators](/procfwk/orchestrators) infant [pipeline](/procfwk/pipelines) emails are sent by the framework using the [Send Email](/procfwk/sendemail) Azure [Function](/procfwk/functions).

For re-use outside of the processing framework the email sender is also wrapped up as a utilities pipeline that exposes email content as pipeline level parameters.

___