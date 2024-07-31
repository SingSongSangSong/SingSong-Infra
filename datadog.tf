# # Use the Datadog Forwarder to ship logs from S3 and CloudWatch, as well as observability data from Lambda functions to Datadog. For more information, see https://github.com/DataDog/datadog-serverless-functions/tree/master/aws/logs_monitoring
# resource "aws_cloudformation_stack" "datadog_forwarder" {
#   name         = "datadog-forwarder"
#   capabilities = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]
#   parameters   = {
#     DdApiKey            = var.datadog_api_key,
#     DdSite              = var.datadog_url,
#     FunctionName        = "datadog-forwarder"
#   }
#   template_url = "https://datadog-cloudformation-template.s3.amazonaws.com/aws/forwarder/latest.yaml"
# }