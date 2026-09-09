# portale its - infrastruttura
# fatto da Marco, marzo 2024

provider "aws" {
  region     = "eu-south-1"
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  s3_use_path_style           = true

  endpoints {
    s3       = "http://127.0.0.1:5000"
    dynamodb = "http://127.0.0.1:5000"
  }
}

variable "api_token_gestionale" {
  type        = string
  description = "Token per il gestionale. Non hardcodare; passare tramite TF var o TF_VAR_api_token_gestionale"
  sensitive   = true
}

data "aws_caller_identity" "corrente" {}

resource "aws_s3_bucket" "sito" {
  bucket = "portale-its-${data.aws_caller_identity.corrente.account_id}"
  tags   = { Progetto = "portale-its" }
}

resource "aws_s3_bucket_public_access_block" "sito" {
  bucket                  = aws_s3_bucket.sito.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "sito" {
  bucket = aws_s3_bucket.sito.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sito" {
  bucket = aws_s3_bucket.sito.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_dynamodb_table" "iscrizioni" {
  name         = "iscrizioni"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "iscrizioneId"

  attribute {
    name = "iscrizioneId"
    type = "S"
  }
}

output "sito" {
  value = aws_s3_bucket.sito.bucket
}
