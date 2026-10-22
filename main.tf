terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "index.html"
  source       = "${path.module}/recipe-book-egusi/index.html"
  etag         = filemd5("${path.module}/recipe-book-egusi/index.html")
  content_type = "text/html"
}

resource "aws_s3_object" "css_file" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "styles.css"
  source       = "${path.module}/recipe-book-egusi/styles.css"
  etag         = filemd5("${path.module}/recipe-book-egusi/styles.css")
  content_type = "text/css"
}

resource "aws_s3_object" "jpeg_file" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "EGUSI SOUP.jpeg"
  source       = "${path.module}/recipe-book-egusi/EGUSI SOUP.jpeg"
  etag         = filemd5("${path.module}/recipe-book-egusi/EGUSI SOUP.jpeg")
  content_type = "image/jpeg"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for static website"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = var.bucket_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.index_doc

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.bucket_name
    viewer_protocol_policy = "redirect-to-https"
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e88639e58f6" # Managed - Caching Optimized
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

#   wait_for_deployment = false

  tags = {
    Name        = "Cloudfront Distribution"
    Environment = "test"
  }

}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
        Principal = {
          CanonicalUser = aws_cloudfront_origin_access_identity.origin_access_identity.s3_canonical_user_id
        }
      }
    ]
  })

}