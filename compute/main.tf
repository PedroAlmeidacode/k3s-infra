# -- compute/main.tf --

data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["137112412989"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.2.20231026.0-kernel-6.1-x86_64"]
  }

}


resource "random_id" "pa_node_id" {
  byte_length = 2
  count       = var.instance_count
  # it changes when var.key_name changes
  keepers = {
    key_name = var.key_name
  }
}

resource "aws_key_pair" "pa_auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "pa_node" {
  count         = var.instance_count # 1
  instance_type = var.instance_type  # t3.micro
  ami           = data.aws_ami.server_ami.id
  tags = {
    Name = "pa_node-${random_id.pa_node_id[count.index].dec}"
  }
  key_name               = aws_key_pair.pa_auth.id
  vpc_security_group_ids = [var.public_sg]
  subnet_id              = var.public_subnets[count.index]
  user_data = templatefile(var.user_data_path,
    {
      nodename    = "pa-${random_id.pa_node_id[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbuser      = var.dbuser
      dbpass      = var.dbpassword
      dbname      = var.dbname
      myip        = var.access_ip
    }
  )
  root_block_device {
    volume_size = var.volume_size # 10
  }
  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = "ec2-user"
      host = self.public_ip
      private_key = file(var.private_key_path)
    }
    script = "${path.root}/delay.sh"
  }
  # provisioner "local-exec" {
  #   command = templatefile("${path.root}/scp_script.tpl",
  #     {
  #       nodeip           = self.public_ip
  #       k3s_path         = "${path.root}"
  #       nodename         = self.tags.Name
  #       private_key_path = var.private_key_path
  #     }
  #   )
  # }
  provisioner "local-exec" {
    when = destroy
    command = "rm -f ${path.root}/k3s-${self.tags.Name}.yaml"
  }
}

resource "aws_lb_target_group_attachment" "pa_tg_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.pa_node[count.index].id
  port             = var.tg_port
}