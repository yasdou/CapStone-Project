resource "aws_s3_bucket" "s3bucket" {
  bucket = var.s3bucketname

  tags = {
    Name        = var.s3bucketname
  }
}

resource "aws_s3_object" "JellyfinFiles" {
  for_each = fileset("data/", "**/*")
  bucket   = aws_s3_bucket.s3bucket.id
  key      = "data/${each.value}"
  source   = "data/${each.value}"
  etag     = filemd5("data/${each.value}")
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.JellyfinVPC.id
  service_name = "com.amazonaws.us-west-2.s3"
}