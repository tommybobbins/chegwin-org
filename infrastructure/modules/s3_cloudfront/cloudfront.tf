locals {
  region      = var.aws_region
  domain_name = var.domain_name
  subdomain   = "www"
  s3_oac      = replace("s3_oac_${local.subdomain}${var.domain_name}", ".", "_")
}



#############
# S3
#############
module "website" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.0.2"

  bucket_prefix = replace("www.${var.domain_name}", "/\\W/", "")
  attach_policy = true
  policy        = data.aws_iam_policy_document.ui_bucket_policy.json

  block_public_policy     = true
  restrict_public_buckets = true

  website = {
    index_document = "index.html"
    error_document = "index.html"
  }
}

#############
# Cloudfront
#############
module "cdn" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.0.1"

  comment             = format("CloudFront Distribution For %s", local.domain_name)
  aliases             = ["${local.subdomain}.${local.domain_name}", "${local.domain_name}"]
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  enabled             = true


  #create_origin_access_control = true
  origin_access_control = {
    "${local.s3_oac}" = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }

  origin = {
    "${local.s3_oac}" = {
      domain_name               = module.website.s3_bucket_bucket_regional_domain_name
      origin_access_control_key = local.s3_oac
    }
  }

  viewer_certificate = {
    acm_certificate_arn = aws_acm_certificate.ssl_certificate.arn
    ssl_support_method  = "sni-only"
  }

  default_cache_behavior = {
    target_origin_id       = local.s3_oac
    viewer_protocol_policy = "allow-all"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true

    function_association = {
      "viewer-request" = {
        function_arn = aws_cloudfront_function.redirect.arn
      }
    }
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


resource "aws_cloudfront_function" "redirect" {
  name    = replace("redirect-${var.domain_name}", "/\\./", "-")
  runtime = "cloudfront-js-1.0"
  publish = true
  code    = <<-EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    var host = request.headers.host.value;

    // Check if the URI matches the path you want to redirect
    if (uri === '/stanley-peck' || uri.startsWith('/stanley-peck/')) {
        var response = {
            statusCode: 301,
            statusDescription: 'Moved Permanently',
            headers: {
                'location': { value: `https://stanleypeck.uk/` }
            }
        };
        return response;
    }

    return request;
}
EOF
}
