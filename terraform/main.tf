provider "aws" {}

resource "aws_s3_bucket" "qc_bucket" {
  bucket        = "queer.church"
  force_destroy = true

  tags {
    Name = "queerchurch"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_cloudfront_distribution" "qc_distribution" {
  aliases = ["*.queer.church", "queer.church"]
  enabled = true

  default_cache_behavior {
    allowed_methods = ["HEAD", "GET"]
    cached_methods  = ["HEAD", "GET"]
    compress        = false
    default_ttl     = 0

    forwarded_values = {
      cookies = {
        forward = "none"
      }

      query_string = "false"
    }

    target_origin_id       = "S3-queer.church"
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name = "queer.church.s3-website-us-west-2.amazonaws.com"
    origin_id   = "S3-queer.church"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  restrictions = {
    geo_restriction = {
      restriction_type = "none"
    }
  }

  viewer_certificate = {
    acm_certificate_arn = "arn:aws:acm:us-east-1:617580300246:certificate/889edd32-6b77-4229-91b4-15153575bd26"
    ssl_support_method  = "sni-only"
  }
}
