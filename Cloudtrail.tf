# data "aws_caller_identity" "current" {}

# resource "aws_cloudtrail" "jellylog" {
#   name                          = "jellylog"
#   s3_bucket_name                = aws_s3_bucket.jellylog.id
#   s3_key_prefix                 = "prefix"
#   include_global_service_events = false
# }

# resource "aws_s3_bucket" "jellylog" {
#   bucket        = "jellylog"
#   force_destroy = true
# }

# data "aws_iam_policy_document" "jellylog" {
#   statement {
#     sid    = "AWSCloudTrailAclCheck"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     actions   = ["s3:GetBucketAcl"]
#     resources = [aws_s3_bucket.jellylog.arn]
#   }

#   statement {
#     sid    = "AWSCloudTrailWrite"
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["cloudtrail.amazonaws.com"]
#     }

#     actions   = ["s3:PutObject"]
#     resources = ["${aws_s3_bucket.jellylog.arn}/prefix/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

#     condition {
#       test     = "StringEquals"
#       variable = "s3:x-amz-acl"
#       values   = ["bucket-owner-full-control"]
#     }
#   }
# }
# resource "aws_s3_bucket_policy" "foo" {
#   bucket = aws_s3_bucket.jellylog.id
#   policy = data.aws_iam_policy_document.jellylog.json
# }