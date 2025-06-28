---
title: "Cloudfront with Origin Access Control, S3 bucket and terraform/tofu"
date: "2025-06-28"
author: "Tim Gibbon"
tags: ["cloudfront","oac","terraform","tofu"]
keywordss: ["cloudfront","oac","terraform","tofu"]
description : "Raging against the lack of recipes: Cloudfront OAC and S3 bucket configuration, a working example"
type: "post"
showTableOfContents: true
---

# Introduction

I've been struggling to find a simple working example for using Cloudfront with S3 buckets and OAC. Here's my working example. The full code can be found in [github](https://github.com/tommybobbins/chegwin-org/).


```
locals {
  region      = "us-east-1"
  domain_name = "mysite.com"
  subdomain   = "www"
}


#############
# Cloudfront
#############
module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "4.1.0"

  comment             = format("CloudFront Distribution For %s", local.domain_name)
  aliases             = ["${local.subdomain}.${local.domain_name}","${local.domain_name}"]
  default_root_object = "index.html"
  price_class = "PriceClass_100"
  enabled = true
  

  create_origin_access_control = true
   origin_access_control = {
    "s3_oac_${local.subdomain}" = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  
  origin = {
   s3_oac = { 
   domain_name = module.website.s3_bucket_bucket_regional_domain_name
   origin_access_control = "s3_oac_${local.subdomain}"
   }
  }

  viewer_certificate = {					  
    acm_certificate_arn = aws_acm_certificate.ssl_certificate.arn
    ssl_support_method  = "sni-only"				
  }							

  default_cache_behavior = {
    target_origin_id           = "s3_oac"
    viewer_protocol_policy     = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

custom_error_response = [
  {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  },
  {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }
]

}

```