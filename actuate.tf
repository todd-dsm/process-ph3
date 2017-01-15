# ------------------------------------------------------------------------------
# This file defines an EC2 instance with:
#   * Origins in the GOLDEN_IMAGE AMI.
#   * Its own security groups.
#   ** That leverages our ssh key(s).
#   * Deploys a simple script.
#   * And fires-up the app with Docker
# vim: et:ts=2:sw=2
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# CONFIGURE THE AWS CONNECTION AND AUTH
# ------------------------------------------------------------------------------
provider "aws" {
  region = "${var.region}"
}
variable "myIPAddress" {}
resource "aws_key_pair" "sysadmin" {
  public_key = "${file("${var.pathKeyPub}")}"
}
resource "aws_key_pair" "builder" {
  public_key = "${file("${var.pathKeyBuilderPub}")}"
}

# -----------------------------------------------------------------------------
# Deploy a single EC2 Instance
# -----------------------------------------------------------------------------
resource "aws_instance" "mobydock" {
  # Debian Jessie Server 8.6 (HVM), SSD Volume Type in us-west-2
  ami = "${data.aws_ami.base_ami.id}"    # should find: "ami-bd2b85dd"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.mobydock_sg.id}"]
  tags {
    Name = "MobyDock-example"
  }
  # Record the IP address of the new machine
  provisioner "local-exec" {
    command = "echo ${aws_instance.mobydock.public_ip} > /tmp/rhost.tfout"
  }
#  # Connection credentials for provisioners
#  connection {
#    user = "${var.instAdminUser}"
#    private_key = "${file("${var.pathKeyPriv}")}"
#  }
#  # Create directories on remote host
#  provisioner "remote-exec" {
#    inline = "mkdir -p /tmp/{sources,scripts}",
#  }
#  # push the contents of the local sources directory up to the remote host
#  # SECFIX: sources/certs/ needs to go somewhere else.
#  provisioner "file" {
#    source = "sources/"
#    destination = "/tmp/sources"
#  }
#  # configure the post-receive hooks, et al.
#  provisioner "file" {
#    source = "scripts/push-prep.sh"
#    destination = "/tmp/scripts/push-prep.sh"
#  }
#  provisioner "remote-exec" {
#    inline = [
#      "chmod u+x /tmp/scripts/push-prep.sh",
#      #"sudo /tmp/scripts/push-prep.sh 2>&1 > /tmp/push-prep.out",
#      "sudo /tmp/scripts/push-prep.sh | tee -ai /tmp/push-prep.out",
#    ]
#  }
#  # Push the code to the remote host
#  provisioner "local-exec" {
#    #command = "scripts/push-code.sh 2>&1 > /tmp/push-code.out"
#    command = "scripts/push-code.sh | tee -ai /tmp/push-code.out"
#  }
#  # push start-service script to the remote host
#  provisioner "file" {
#    source = "scripts/service-init.sh"
#    destination = "/tmp/scripts/service-init.sh"
#  }
#  # Initilize the app
#  provisioner "remote-exec" {
#    inline = [
#      "chmod u+x /tmp/scripts/service-init.sh",
#      #"sudo /tmp/scripts/service-init.sh 2>&1 > /tmp/service-init.out",
#      "sudo /tmp/scripts/service-init.sh | tee -ai /tmp/service-init.out",
#    ]
#  }
}
# -----------------------------------------------------------------------------
# Create a Security Group for the Instance
# -----------------------------------------------------------------------------
resource "aws_security_group" "mobydock_sg" {
  name = "MobyDock-example"
  # Inbound SSH from myOffice
  ingress {
    from_port = "${var.comms_port}"
    to_port   = "${var.comms_port}"
    protocol  = "tcp"
    # TODO: make local ip address dynamic; maybe read from a file?
    cidr_blocks = ["${var.myIPAddress}"]
    #cidr_blocks = ["173.16.140.207/32"]
  }
#  ingress {
#    from_port = "${var.service_port}"
#    to_port   = "${var.service_port}"
#    protocol  = "tcp"
#    cidr_blocks = ["0.0.0.0/0"]
#  }
  ingress {
    from_port = "${var.http_port}"
    to_port   = "${var.http_port}"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "${var.https_port}"
    to_port   = "${var.https_port}"
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow all outbound traffic: for now
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# -----------------------------------------------------------------------------
# Find the latest AMI; NOTE: MUST produce only 1 AMI ID.
# -----------------------------------------------------------------------------
data "aws_ami" "base_ami" {
  most_recent = true
  owners = ["self"]
  #executable_users = ["self"]
  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "description"
    values = ["GOLDEN_IMAGE"]
  }
  filter {
    name = "image-type"
    values = ["machine"]
  }
  filter {
    name = "name"
    values = ["base"]
  }
  filter {
    name = "state"
    values = ["available"]
  }
}
