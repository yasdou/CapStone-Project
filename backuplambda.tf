# # create iam role for lambda function to access s3
# resource "aws_iam_role" "iam_for_lambda" {
#   name = "iam_for_lambda"
  
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })

#   tags = {
#     Name = "iam_for_lambda"
#   }
# }

# data "aws_iam_policy_document" "lambda_policy" {
#   version = "2012-10-17"

#   statement {
#     sid    = "LambdaS3GetObject"
#     effect = "Allow"
#     actions = [
#       "s3:GetObject",
#       "s3:ListBucket",
#     ]
#     resources = [
#       "${aws_s3_bucket.s3bucket.arn}/*",
#       "${aws_s3_bucket.s3bucket.arn}",
#     ]
#   }

#   statement {
#     sid    = "LambdaS3PutObject"
#     effect = "Allow"
#     actions = [
#       "s3:PutObject",
#     ]
#     resources = [
#       "${aws_s3_bucket.s3backupbucket.arn}/*",
#       "${aws_s3_bucket.s3backupbucket.arn}",
#     ]
#   }
# }

# resource "aws_iam_policy" "lambda_policy" {
#   name        = "lambda-policy"
#   policy      = data.aws_iam_policy_document.lambda_policy.json
# }

# resource "aws_iam_role_policy_attachment" "iam_for_lambda_policy_attachment" {
#   policy_arn = aws_iam_policy.lambda_policy.arn
#   role       = aws_iam_role.iam_for_lambda.name
# }

# #deploy lambda function with python script

# data "archive_file" "lambda" {
#   type        = "zip"
#   source_file = "${path.module}/scripts/backup.py"
#   output_path = "${path.module}/scripts/lambda_function_payload.zip"
# }

# resource "aws_lambda_function" "backup_jellyfin" {
#   # If the file is not in the current working directory you will need to include a
#   # path.module in the filename.
#   filename      = "${path.module}/scripts/lambda_function_payload.zip"
#   function_name = "backup_jellyfin"
#   role          = aws_iam_role.iam_for_lambda.arn
#   timeout = 300
#   memory_size = 3008
#   handler = "backup.lambda_handler"
#   ephemeral_storage {
#     size = 5000
#   }

#   source_code_hash = data.archive_file.lambda.output_base64sha256

#   runtime = "python3.10"
# }

# #trigger lambda function through cloudwatch event

resource "aws_cloudwatch_event_rule" "once_a_day" {
    name = "every-five-minutes"
    description = "Fires once a day"
    schedule_expression = "rate(24 hours)"
}

# resource "aws_cloudwatch_event_target" "check_foo_once_a_day" {
#     rule = aws_cloudwatch_event_rule.once_a_day.name
#     target_id = "backup_jellyfin"
#     arn = aws_lambda_function.backup_jellyfin.arn
# }

# resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
#     statement_id = "AllowExecutionFromCloudWatch"
#     action = "lambda:InvokeFunction"
#     function_name = aws_lambda_function.backup_jellyfin.function_name
#     principal = "events.amazonaws.com"
#     source_arn = aws_cloudwatch_event_rule.once_a_day.arn
# }