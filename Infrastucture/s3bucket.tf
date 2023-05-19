#create s3 bucket for jellyfin config and media
resource "aws_s3_bucket" "s3bucket" {
  bucket = var.s3bucketname

  tags = {
    Name        = var.s3bucketname
  }
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.JellyfinVPC.id
  service_name = "com.amazonaws.us-west-2.s3"
}

#upload config and media
resource "aws_s3_object" "JellyfinFiles" {
  for_each = fileset("data/", "**/*")
  bucket   = aws_s3_bucket.s3bucket.id
  key      = "data/${each.value}"
  source   = "data/${each.value}"
}

#create s3 backup bucket

resource "aws_s3_bucket" "s3backupbucket" {
  bucket = var.s3backupbucketname

  tags = {
    Name        = var.s3backupbucketname
  }
}
