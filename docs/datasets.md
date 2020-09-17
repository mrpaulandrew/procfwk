# Datasets
___

[<< Contents](/procfwk/contents) / [Data Factory](/procfwk/datafactory)

___
![Dataset Icon](/procfwk/dataset.png){:style="float: right;margin-left: 15px;margin-bottom: 10px;"}The processing framework requires only one dataset to run. In the development code repository this is called __GetSetMetadata__. This dataset offers all Lookup and Stored Procedure [activities](/procfwk/activities) within the framework [pipelines](/procfwk/pipelines) the ability to call and query [database](/procfwk/database) objects.

As the scope of the framework is to operate at the control flow level within a given solution, datasets used for data transformation are not within the remit of the framework. However, if you are using a single Data Factory instance for both the framework [pipelines](/procfwk/pipelines) and the worker pipeline processing tasks other datasets can be created as required.