data "local_file" "hoge" {
  filename = "${path.module}/hoge"
}

resource "null_resource" "hoge" {
  count = length(data.local_file.hoge.content) > 0 ? 1 : 0

  provisioner "local-exec" {
    command = <<EOF
cat "${path.module}/${data.local_file.hoge.filename}"
EOF
  }
}

output "hogehoge" {
  value = "${data.local_file.hoge.filename}"
}