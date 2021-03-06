# Store terraform state in s3
terraform {
  backend "s3" {
    bucket = "opstest-terra-state"
    key    = "test/terraform.tfstate"
    region = "eu-west-1"
  }
}

# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_elb" "web-elb" {
  name = "opstest-${var.env}-elb"
  source_security_group = "opstest-${var.env}-elb-sg"
  # The same availability zone as our instances
  availability_zones = ["${split(",", var.availability_zones)}"]

  listener {
    instance_port     = 8080
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8080/hello"
    interval            = 30
  }
}

resource "aws_autoscaling_group" "web-asg" {
  availability_zones   = ["${split(",", var.availability_zones)}"]
  # Dynamic name to ensure ASG is recreated during deployments
  # and, therefore a  whole new cluster will be deployed using last AMI
  name                 = "${aws_launch_configuration.web-lc.name}-asg"
  max_size             = "${var.asg_max}"
  min_size             = "${var.asg_min}"
  desired_capacity     = "${var.asg_desired}"
  # Use ELB healthchekc to determine state
  health_check_grace_period = 200
  health_check_type         = "ELB"
  launch_configuration = "${aws_launch_configuration.web-lc.name}"
  load_balancers       = ["${aws_elb.web-elb.name}"]
  wait_for_elb_capacity = "${var.asg_desired}"
  #vpc_zone_identifier = ["${split(",", var.availability_zones)}"]
  tag {
    key                 = "Name"
    value               = "web-asg"
    propagate_at_launch = "true"
  }

  lifecycle {
    create_before_destroy = true
  }

}


resource "aws_launch_configuration" "web-lc" {
  name_prefix   = "opstest-${var.env}-lc"
  image_id      = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "${var.instance_type}"

  lifecycle {
    create_before_destroy = true
  }


  # Security group
  security_groups = ["${aws_security_group.default.id}"]
  key_name        = "${var.key_name}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "default" {
  name        = "opstest_${var.env}_sg"
  description = "Used in the terraform"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP port 8080 access from ELB security group
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = ["${aws_elb.web-elb.source_security_group_id}"]
  }

  # Allow any outgoing traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
