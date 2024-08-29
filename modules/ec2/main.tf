data "aws_ami" "find_ami" {
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.20240819.0-kernel-6.1-x86_64"]
  }
}

variable "file_name" {
  description = "Name of the key pair"
  type        = string
  default     = "id_rsa"
}
# RSA key of size 4096 bits
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = var.file_name
}

resource "aws_key_pair" "our_key" {
  key_name   = "our_key"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "aws_instance" "not-a-vm" {
  ami                    = data.aws_ami.find_ami.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  tags = merge(
    {
      Name = "web-server"
    }
  )
  key_name  = aws_key_pair.our_key.key_name
  user_data = file("./modules/ec2/webinstall.sh")


  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo yum update -y",
  #     "sudo yum install httpd -y",
  #     "sudo systemctl enable httpd",
  #     "sudo systemctl start httpd",
  #     "sudo sh -c 'echo NotAWebPage > /var/www/html/index.html'",
  #     "echo ${self.public_ip}"
  #   ]

  #   connection {
  #     host        = self.public_ip
  #     private_key = file(var.file_name)
  #     type        = "ssh"
  #     user        = "ec2-user"
  #   }
  # }
}

resource "local_file" "ec2_instance_info" {
  content  = "Instance Name: ${aws_instance.not-a-vm.tags["Name"]}\nPublic IP: ${aws_instance.not-a-vm.public_ip}\nPrivate IP: ${aws_instance.not-a-vm.private_ip}"
  filename = "ec2_${aws_instance.not-a-vm.tags["Name"]}.txt"
}


output "instance_name" {
  value = aws_instance.not-a-vm.tags["Name"]
}

output "public_ip" {
  value = aws_instance.not-a-vm.public_ip
}

output "private_ip" {
  value = aws_instance.not-a-vm.private_ip
}
