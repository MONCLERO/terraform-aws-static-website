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