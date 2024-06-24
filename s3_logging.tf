#Creation of logging Bucket
resource "aws_s3_bucket" "acme-demo-waf-security" {
  bucket = "acme-demo-waf-security"
  tags = {
    name = "WAf logging"
  }
}

#Creation of bucket acl for logging purposes
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.acme-demo-waf-security.id
  acl    = "log-delivery-write"
}

#Bucket SSE encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.acme-demo-waf-security.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

#Bucket lifecycle configuration
resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.acme-demo-waf-security.id

  rule {
    id = "log"
    filter {
      and {
        prefix = "log/"

        tags = {
          rule      = "log"
          autoclean = "true"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    
    expiration {
      days = 90
    }

  }
}