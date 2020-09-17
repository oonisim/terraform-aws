#  At present this resource can only retrieve data from URLs that respond with text/*
# or application/json content types, and expects the result to be UTF-8 encoded
# regardless of the returned content type header.
/*
data "http" "s3_web_index_html" {
  url = "https://${local.cf_web_domain_name}/${local.s3_web_index_html_key}"
  request_headers = {
    "Accept" = "text/html"
  }
}

output "s3_web_index_html" {
  value = data.http.s3_web_index_html.body
}
*/