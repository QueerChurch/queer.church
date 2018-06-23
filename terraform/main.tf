locals {
  domain = "queer.church"
  index  = "index.html"
  name   = "queerchurch"
  region = "us-west-2"
}

provider "aws" {}

resource "aws_s3_bucket" "qc_bucket" {
  bucket        = "${local.domain}"
  force_destroy = true
  region        = "${local.region}"

  tags {
    Name = "${local.name}"
  }

  website {
    index_document = "${local.index}"
    error_document = "${local.index}"
  }
}

resource "aws_cloudfront_distribution" "qc_distribution" {
  aliases = ["*.${local.domain}", "${local.domain}"]
  enabled = true

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]
    compress        = false
    default_ttl     = 0

    forwarded_values {
      cookies {
        forward = "none"
      }

      query_string = "false"
    }

    target_origin_id       = "S3-${local.domain}"
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name = "${local.domain}.s3-website-${local.region}.amazonaws.com"
    origin_id   = "S3-${local.domain}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags {
    Name = "${local.name}"
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:617580300246:certificate/889edd32-6b77-4229-91b4-15153575bd26"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_zone" "qc_zone" {
  name = "${local.domain}."

  tags {
    Name = "${local.name}"
  }
}
