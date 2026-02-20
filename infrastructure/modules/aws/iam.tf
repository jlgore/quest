resource "aws_iam_role" "this" {
  name = "quest-ecs-task-execution-role-with-secrets"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "this" {
  name = "quest-ecs-secrets-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = [
        "secretsmanager:GetSecretValue",
        "kms:Decrypt" # Required if using a custom KMS key
      ],
      Effect   = "Allow",
      Resource = aws_secretsmanager_secret.this.arn
    },
    {
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Effect   = "Allow",
      Resource = "arn:aws:logs:*:*:*"
    }]
  })
}
