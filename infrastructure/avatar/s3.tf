resource "aws_s3_bucket" "avatars" {
  bucket = "saf-grocery-store-v3"
}

resource "aws_s3_bucket_versioning" "avatars_versioning" {
  bucket = aws_s3_bucket.avatars.id
  versioning_configuration {
    status = "Enabled"
  }
}
