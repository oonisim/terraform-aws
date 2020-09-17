locals {
  user_data = templatefile(
    "${path.module}/userdata/userdata.template",
    {
      firehose_name = "${var.firehose_name}"
      file_pattern  = "/var/log/httpd/access_log"
      region        = "${data.aws_region.current.name}"
    }
  )
}
