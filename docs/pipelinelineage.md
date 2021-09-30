# Pipeline Lineage

___
[<< Contents](/procfwk/contents) 

___

To support and inform operational teams working with the processing framework solution pipeline lineage documentation and diagrams can be auto generated from the metadata database.

This can be done using the Markdown extention Mermaid.

https://mermaid-js.github.io/mermaid

To generate the Mermaid markdown, within the framework metadata database the following stored procedure can be used.

```sql
EXEC [procfwkHelpers].[GetMermaidPipelineLineageMarkdown]
	@BatchName = 'Daily' --optional
```

Within a markdown rendering service the Mermaid output can then be used to generated a pipeline lineage diagram similar to the below.

```mermaid
graph LR
subgraph Daily
style Daily fill:#DEEBF7,stroke:#DEEBF7
subgraph FrameworkFactory
style FrameworkFactory fill:#E2F0D9,stroke:#E2F0D9
subgraph Extract
style Extract fill:#FFF2CC,stroke:#FFF2CC
p10(Wait 1)
style p10 fill:#F2F2F2,stroke:#F2F2F2
p20(Wait 2)
style p20 fill:#F2F2F2,stroke:#F2F2F2
p30(Intentional Error)
style p30 fill:#F2F2F2,stroke:#F2F2F2
p40(Wait 3)
style p40 fill:#F2F2F2,stroke:#F2F2F2
end
subgraph Load
style Load fill:#FFF2CC,stroke:#FFF2CC
p90(Wait 8)
style p90 fill:#F2F2F2,stroke:#F2F2F2
p100(Wait 9)
style p100 fill:#F2F2F2,stroke:#F2F2F2
end
subgraph Transform
style Transform fill:#FFF2CC,stroke:#FFF2CC
p50(Wait 4)
style p50 fill:#F2F2F2,stroke:#F2F2F2
p60(Wait 5)
style p60 fill:#F2F2F2,stroke:#F2F2F2
p70(Wait 6)
style p70 fill:#F2F2F2,stroke:#F2F2F2
p80(Wait 7)
style p80 fill:#F2F2F2,stroke:#F2F2F2
end
end
subgraph WorkersFactory
style WorkersFactory fill:#E2F0D9,stroke:#E2F0D9
subgraph Serve
style Serve fill:#FFF2CC,stroke:#FFF2CC
p110(Wait 10)
style p110 fill:#F2F2F2,stroke:#F2F2F2
end
end
s100[Extract]
style s100 fill:#FFF2CC,stroke:#FFF2CC
s200[Transform]
style s200 fill:#FFF2CC,stroke:#FFF2CC
s300[Load]
style s300 fill:#FFF2CC,stroke:#FFF2CC
s400[Serve]
style s400 fill:#FFF2CC,stroke:#FFF2CC
s100 --> p10
s100 --> p20
s100 --> p30
s100 --> p40
s200 --> p50
s200 --> p60
s200 --> p70
s200 --> p80
s300 --> p90
s300 --> p100
s400 --> p110
s100 ==> s200
s200 ==> s300
s300 ==> s400
p30 -.- p60
p30 -.- p70
p70 -.- p100
p100 -.- p110
end
```
