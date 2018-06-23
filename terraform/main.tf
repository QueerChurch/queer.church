provider "aws" {}

resource "aws_s3_bucket" "qc_bucket" {
  acl    = "public-read"
  bucket = "queer.church"

  tags {
    Name = "queerchurch"
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}
