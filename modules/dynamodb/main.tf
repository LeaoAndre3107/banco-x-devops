resource "aws_dynamodb_table" "contas" {
  name         = "${var.project}-${var.environment}-contas"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "conta_id"

  attribute {
    name = "conta_id"
    type = "S"
  }

  tags = {
    Name        = "${var.project}-${var.environment}-contas"
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}