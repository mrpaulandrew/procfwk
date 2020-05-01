// Databricks notebook source
import scala.util.Try

dbutils.widgets.text("RaiseError", "","")


// COMMAND ----------

val raiseError = Try(dbutils.widgets.get("RaiseError").toBoolean).getOrElse(false)

if(raiseError)
{
  throw new Exception("The Notebook intentionally failed.")
}
