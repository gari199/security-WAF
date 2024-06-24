provider "aws" {
  region = var.region
}

#Creation of ALB
resource "aws_lb" "waf-alb" {
  name               = "waf-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_security_group.waf-alb-sg.id]
  subnets            = [var.subnet_id_1,var.subnet_id_2,var.subnet_id_3]

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.acme-demo-waf-security.id
    prefix  = "waf-alb"
    enabled = true
  }

  tags = {
    Environment = "production"
  }
}

#Data from security group
data "aws_security_group" "waf-alb-sg" {
  id = var.security_group_id
}

#Global Web ACL
resource "aws_wafv2_web_acl" "security-waf" {
  name        = "WAF-rules-global"
  description = "The ACL rules for the Web Application Firewall"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "blacklist"
    priority = 1
    action {
      block {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.blacklisted_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "blacklist"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "whitelist"
    priority = 2
    action {
      allow {}
    }
    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelisted_ips.arn
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "whitelist"
      sampled_requests_enabled   = false
    }
  }
  rule {
    name     = "rate-limit-global"
    priority = 3
    action {
      block {}
    }
    statement {
      rate_based_statement {
        limit = 10000
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-global"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "rate-limit-different-country"
    priority = 4
    action {
      count {}
    }
    statement {
      rate_based_statement {
        limit = 1000
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rate-limit-different-country"
      sampled_requests_enabled   = true
    }
  }

  rule {      #https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 5
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name     = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }

  }

  rule {       #https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
    name     = "AWSManagedRulesCommonRuleSet" 
    priority = 6
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        # to set a rule to only count instead of block
        # add an 'excluded_rule' block like this:
        #excluded_rule {
          #name = "SizeRestrictions_QUERYSTRING"
        #}
        #
        # active blocking rules are:
        #   "SizeRestrictions_Cookie_HEADER"
        #   "EC2MetaDataSSRF_BODY"
        #   "EC2MetaDataSSRF_COOKIE"
        #   "EC2MetaDataSSRF_URIPATH"
        #   "EC2MetaDataSSRF_QUERYARGUMENTS"
        #   "GenericLFI_QUERYARGUMENTS"
        #   "GenericLFI_URIPATH"
        #   "GenericLFI_BODY"
        #   "GenericRFI_QUERYARGUMENTS"
        #   "GenericRFI_BODY"
        #   "GenericRFI_URIPATH"
        #   "CrossSiteScripting_COOKIE"
        #   "CrossSiteScripting_QUERYARGUMENTS"
        #   "CrossSiteScripting_URIPATH"
        #   "NoUserAgent_HEADER" --
        #   "SizeRestrictions_BODY"
        #   "SizeRestrictions_URIPATH"
        #   "RestrictedExtensions_URIPATH"
        #   "RestrictedExtensions_QUERYARGUMENTS"
        #   "CrossSiteScripting_BODY"
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "CommonRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {        #https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-ip-rep.html
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 7
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {      #https://docs.aws.amazon.com/waf/latest/developerguide/aws-managed-rule-groups-baseline.html
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 8
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name     = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "KnownBadInputsRuleSet"
      sampled_requests_enabled   = true
    }

  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WafAcl"
    sampled_requests_enabled   = true
  }
  tags = {
      "Name"        = "security-waf"
    }
}

resource "aws_wafv2_web_acl_logging_configuration" "waf_acl_logging" {
  resource_arn            = aws_wafv2_web_acl.security-waf.arn
  log_destination_configs = [aws_s3_bucket.acme-demo-waf-security.arn]
  logging_filter {
    default_behavior = "DROP"
    filter {
      behavior    = "KEEP"
      condition {
        action_condition {
          action = "COUNT"
        }
      }
      condition {
        action_condition {
          action = "BLOCK"
        }
      }
      requirement = "MEETS_ANY"
    }
  }
}

resource "aws_wafv2_web_acl_association" "acl_alb_association" {
  resource_arn = aws_lb.waf-alb.arn
  web_acl_arn  = aws_wafv2_web_acl.security-waf.arn
}