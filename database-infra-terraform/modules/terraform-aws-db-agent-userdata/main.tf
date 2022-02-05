# Render a part using a `template_file`
data "template_file" "db_agent_userdata" {
  template           = "${file("${path.module}/db-agent-userdata.sh")}"

  vars = {
    s3_bucket        = var.s3_bucket
    rds_pwd          = var.rds_pwd
    rds_address      = var.rds_address
    rds_user         = var.rds_user
    rds_db           = var.rds_db
    
  }
}

# Render a multi-part cloudinit config making use of the part above, and other source files
data "template_cloudinit_config" "config" {
  gzip              = false
  base64_encode     = true

  part {
    filename        = "db-agent-userdata.sh"
    content_type    = "text/x-shellscript"
    content         = data.template_file.db_agent_userdata.rendered
  }
}