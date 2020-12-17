# Invalid Request Exception

___
[<< Contents](/procfwk/contents) / [Functions](/procfwk/functions) / [Helpers](/procfwk/helpers)

___

## Inherits

- [Exception](https://docs.microsoft.com/en-us/dotnet/api/system.exception){:target="_blank"}

## Role

To provide a custom exception that can be used to throw detailed errors specific to the framework support functions.

Namespace: __mrpaulandrew.azure.procfwk.Helpers__.

## Methods

```csharp
public InvalidRequestException()
{
}

public InvalidRequestException(string message) : base(message)
{
}

public InvalidRequestException(string message, Exception innerException) : base(message, innerException)
{
}

protected InvalidRequestException(SerializationInfo info, StreamingContext context) : base(info, context)
{
}
```

___