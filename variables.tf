variable "aws_region" {
  type = string
  description = "Region for s3 bucket creation"
  default = "us-east-1"
}

variable "bucket_name" {
  type        = string
  description = "The name of s3 bucket."
  default     = "mybucket-09073249330"
}

variable "index_doc" {
  type        = string
  description = "This is the websites index document"
  default     = "index.html"
}