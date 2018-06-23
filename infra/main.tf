locals {
  domain = "queer.church"
  name   = "queerchurch"
}

provider "aws" {}

resource "aws_s3_bucket" "qc_bucket" {
  bucket        = "${local.domain}"
  force_destroy = true

  tags {
    Name = "${local.name}"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_acm_certificate" "qc_certificate" {
  domain_name               = "${local.domain}"
  subject_alternative_names = ["*.${local.domain}"]
  validation_method         = "DNS"

  tags {
    Name = "${local.name}"
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

    target_origin_id       = "${local.domain}"
    viewer_protocol_policy = "redirect-to-https"
  }

  origin {
    domain_name = "${aws_s3_bucket.qc_bucket.website_endpoint}"
    origin_id   = "${local.domain}"

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
    acm_certificate_arn = "${aws_acm_certificate.qc_certificate.arn}"
    ssl_support_method  = "sni-only"
  }
}

resource "aws_route53_zone" "qc_zone" {
  name = "${local.domain}."

  tags {
    Name = "${local.name}"
  }
}

resource "aws_route53_record" "qc_record_root" {
  name    = "${local.domain}."
  type    = "A"
  zone_id = "${aws_route53_zone.qc_zone.zone_id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.qc_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.qc_distribution.hosted_zone_id}"
  }
}

resource "aws_route53_record" "qc_record_wild" {
  name    = "*.${local.domain}."
  type    = "A"
  zone_id = "${aws_route53_zone.qc_zone.zone_id}"

  alias {
    evaluate_target_health = false
    name                   = "${aws_cloudfront_distribution.qc_distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.qc_distribution.hosted_zone_id}"
  }
}

resource "aws_route53_record" "qc_record_validation" {
  count   = "${length(aws_acm_certificate.qc_certificate.domain_validation_options)}"
  name    = "${aws_acm_certificate.qc_certificate.*.domain_validation_options.resource_record_name[count.index]}"
  records = ["${aws_acm_certificate.qc_certificate.*.domain_validation_options.resource_record_value[count.index]}"]
  ttl     = 60
  type    = "${aws_acm_certificate.qc_certificate.*.domain_validation_options.resource_record_type[count.index]}"
  zone_id = "${aws_route53_zone.qc_zone.zone_id}"
}

resource "aws_acm_certificate_validation" "qc_validation" {
  certificate_arn         = "${aws_acm_certificate.qc_certificate.arn}"
  validation_record_fqdns = ["${aws_route53_record.qc_record_validation.fqdn}"]
}
