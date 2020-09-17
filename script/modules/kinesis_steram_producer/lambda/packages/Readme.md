Create a proper zip file for etag to check.
```
touch upload && zip upload.zip upload
```

etag fails if there is no target object to upload exists for the first time.


```
resource "aws_s3_bucket_object" "lambda_kinesis_producer_package" {
  bucket                 = "${aws_s3_bucket.package.bucket}"
  key                    = "${var.lambda_kinesis_producer_archive}"
  #storage_class          = "GLACIER
  storage_class          = "STANDARD_IA"
  #server_side_encryption = "AES256"

  #source                 = "${data.archive_file.lambda_kinesis_producer.output_path}"
  #etag                   = "${md5(file("${data.archive_file.lambda_kinesis_producer.output_path}"))}"
  source                 = "${path.module}/${var.lambda_kinesis_producer_archive}"
  
  #--------------------------------------------------------------------------------
  # etag fails if there is no target object to upload exists for the first time.
  # Create a dummpy/empty object.
  #--------------------------------------------------------------------------------
  etag                   = "${md5(file("${path.module}/${var.lambda_kinesis_producer_archive}"))}" <---

  depends_on = [
    "null_resource.archive",
  ]
}
```