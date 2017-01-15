# -----------------------------------------------------------------------------
# OUTPUTS
# -----------------------------------------------------------------------------
output "ip" {
  value = "${aws_instance.mobydock.public_ip}"
}

output "mobydock_sg" {
  value = "${aws_security_group.mobydock_sg.id}"
}

output "myIP" {
 value = "${var.myIPAddress}"
}

