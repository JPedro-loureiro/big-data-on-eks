resource "aws_glue_catalog_database" "datalake_bronze" {
  name         = "datalake_bronze"
  location_uri = "s3://${aws_s3_bucket.dl_bronze_layer.id}"
}

resource "aws_glue_catalog_database" "datalake_silver" {
  name         = "datalake_silver"
  location_uri = "s3://${aws_s3_bucket.dl_silver_layer.id}"
}

resource "aws_glue_catalog_database" "datalake_gold" {
  name         = "datalake_gold"
  location_uri = "s3://${aws_s3_bucket.dl_gold_layer.id}"
}