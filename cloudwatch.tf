resource "aws_cloudwatch_log_group" "singsong_log_group" {
  name              = "/ecs/singsong-golang"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "singsong_milvus_log_group" {
  name              = "/ecs/milvus-task"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "singsong_embedding_log_group" {
  name              = "/ecs/singsong-embedding"
  retention_in_days = 7
}