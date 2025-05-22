# ses.tf

resource "aws_ses_domain_identity" "ses_domain" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "ses_domain_dkim" {
  domain = aws_ses_domain_identity.ses_domain.domain
}

resource "aws_ses_email_identity" "notification_email" {
  email = var.notification_email
}

resource "aws_ses_email_identity" "sender_email" {
  email = var.sender_email
}

resource "aws_ses_email_identity" "confirmation_sender_email" {
  email = var.confirmation_sender_email
}

resource "aws_ses_configuration_set" "ses_config" {
  name = "buzser-email-config"
}

resource "aws_ses_event_destination" "bounce_handling" {
  name                   = "event-destination-bounce"
  configuration_set_name = aws_ses_configuration_set.ses_config.name
  enabled                = true
  matching_types         = ["bounce", "complaint"]

  sns_destination {
    topic_arn = aws_sns_topic.email_bounces.arn
  }
}

resource "aws_sns_topic" "email_bounces" {
  name = "email-bounces"
}

resource "aws_ses_receipt_rule_set" "main" {
  rule_set_name = "buzser-rules"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
}

resource "aws_ses_receipt_rule" "forward" {
  name          = "forward-replies"
  rule_set_name = aws_ses_receipt_rule_set.main.rule_set_name
  recipients    = ["hello@buzser.com"]
  enabled       = true
  scan_enabled  = true

  add_header_action {
    header_name  = "X-Forward-To"
    header_value = "chris.hickey@buzser.com"
    position     = 1
  }

  stop_action {
    scope    = "RuleSet"
    position = 2
  }
}
output "ses_verification_token" {
  description = "The verification token for the SES domain"
  value       = aws_ses_domain_identity.ses_domain.verification_token
}

output "dkim_tokens" {
  description = "The DKIM tokens for the SES domain"
  value       = aws_ses_domain_dkim.ses_domain_dkim.dkim_tokens
}