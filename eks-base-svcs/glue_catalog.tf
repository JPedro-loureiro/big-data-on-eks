resource "aws_glue_catalog_database" "datalake_bronze" {
  name         = "datalake_bronze"
  location_uri = "s3://${aws_s3_bucket.dl_bronze_layer.id}"
}