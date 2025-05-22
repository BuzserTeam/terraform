# pinpoint.tf

resource "aws_pinpoint_app" "buzser_pinpoint" {
  name = "${var.project_name}-${var.environment}"

  limits {
    daily               = 100 # Changed from 5000 to 100 (max allowed)
    maximum_duration    = 60
    messages_per_second = 50
    total               = 100 # Changed from 100000 to 100 (max allowed)
  }
}


resource "aws_pinpoint_email_channel" "email" {
  application_id = aws_pinpoint_app.buzser_pinpoint.application_id
  from_address   = var.sender_email
  identity       = aws_ses_domain_identity.ses_domain.arn
  role_arn       = aws_iam_role.pinpoint_role.arn
  enabled        = true
}

resource "aws_iam_role" "pinpoint_role" {
  name = "${var.project_name}-pinpoint-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "pinpoint.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "pinpoint_policy" {
  name        = "${var.project_name}-pinpoint-policy"
  description = "Policy for Pinpoint email sending"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "pinpoint_policy_attachment" {
  role       = aws_iam_role.pinpoint_role.name
  policy_arn = aws_iam_policy.pinpoint_policy.arn
}