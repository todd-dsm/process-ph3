# -----------------------------------------------------------------------------
# ENVIRONMENT VARIABLES
# Define these secrets as environment variables
# vim: et:ts=2:sw=2
# -----------------------------------------------------------------------------
variable "region" {
  description = "The default DEV region"
  default = "us-west-2"
}
variable "pathKeyPriv" {
  default = "~/.ssh/id_rsa"
}
variable "pathKeyPub" {
  default = "~/.ssh/id_rsa.pub"
}
variable "pathKeyBuilderPriv" {
  default = "~/.ssh/builder"
}
variable "pathKeyBuilderPub" {
  default = "~/.ssh/builder.pub"
}
variable "instAdminUser" {
  default = "admin"
}

# -----------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# -----------------------------------------------------------------------------
# AMIs by Region
variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-2808313f"    # N. Virginia
    us-west-1 = "ami-be376ecd"    # NoCal
    us-west-2 = "ami-7df25b1d"    # Oregon
  }
}
# Define COMMS port
variable "comms_port" {
  description = "The port the server will use for SSH requests"
  default = 22
}

# Define web call
variable "http_port" {
  description = "The port used for outbound HTTP service requests"
  default = 80
}

# Define Secure web call
variable "https_port" {
  description = "The port used for outbound HTTPS service requests"
  default = 443
}

# Define the app port
variable "service_port" {
  description = "The port the server will use for HTTP requests"
  default = 8000
}

