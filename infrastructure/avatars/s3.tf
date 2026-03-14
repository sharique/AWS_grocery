resource "aws_s3_bucket" "avatars" {
  bucket = "saf-grocery-store-v3"
}

resource "aws_s3_bucket_versioning" "avatars_versioning" {
  bucket = aws_s3_bucket.avatars.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "avatars" {
  bucket                  = aws_s3_bucket.avatars.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "avatars" {
  bucket = aws_s3_bucket.avatars.id
  rule {
    id     = "expire-old-version"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
