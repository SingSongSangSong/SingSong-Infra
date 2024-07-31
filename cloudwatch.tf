resource "aws_cloudwatch_log_group" "singsong_log_group" {
  name              = "/ecs/singsong"
  retention_in_days = 7
}