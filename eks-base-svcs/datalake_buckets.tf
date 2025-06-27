data "aws_caller_identity" "current_account" {}

resource "aws_s3_bucket" "dl_bronze_layer" {
  bucket        = "datalake-bronze-${data.aws_caller_identity.current_account.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "dl_silver_layer" {
  bucket        = "datalake-silver-${data.aws_caller_identity.current_account.account_id}"
  force_destroy = true
}

resource "aws_s3_bucket" "dl_gold_layer" {
  bucket        = "datalake-gold-${data.aws_caller_identity.current_account.account_id}"
  force_destroy = true
}