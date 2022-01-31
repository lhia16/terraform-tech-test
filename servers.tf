# module "ec2_instances" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "3.4.0"

#   for_each = toset(["one", "two"])

#   name = "instance-${each.key}"

#   ami                    = "ami-00ae935ce6c2aa534"
#   instance_type          = "t2.micro"
#   user_data              = "${file("install-nginx.sh")}"
#   vpc_security_group_ids = [module.vpc.default_security_group_id]
#   subnet_id              = module.vpc.public_subnets[0]

#   tags = {
#     Terraform   = "true"
#     Environment = "dev"
#   }
# }

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 4.0"

  # Autoscaling group
  name = "and-tech-test-asg"

  min_size                  = 2
  max_size                  = 3
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"
  vpc_zone_identifier       = module.vpc.private_subnets
  target_group_arns         = module.alb.target_group_arns


  initial_lifecycle_hooks = [
    {
      name                  = "ExampleStartupLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 60
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "ExampleTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 300
      min_healthy_percentage = 50
    }
    triggers = ["tag"]
  }

  # Launch template
  lt_name                = "example-asg"
  description            = "Launch template example"
  update_default_version = true

  use_lt    = true
  create_lt = true

  image_id          = "ami-00ae935ce6c2aa534"
  instance_type     = "t3.micro"
  ebs_optimized     = true
  enable_monitoring = true
  user_data_base64  = "${filebase64("install-nginx.sh")}"

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 20
        volume_type           = "gp2"
      }
      }, {
      device_name = "/dev/sda1"
      no_device   = 1
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp2"
      }
    }
  ]

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

#   cpu_options = {
#     core_count       = 1
#     threads_per_core = 1
#   }

  credit_specification = {
    cpu_credits = "standard"
  }

#   instance_market_options = {
#     market_type = "spot"
#     spot_options = {
#       block_duration_minutes = 60
#     }
#   }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }

  network_interfaces = [
    {
      delete_on_termination = true
      description           = "eth0"
      device_index          = 0
      security_groups       = [module.vpc.default_security_group_id]
    },
    {
      delete_on_termination = true
      description           = "eth1"
      device_index          = 1
      security_groups       = [module.vpc.default_security_group_id]
    }
  ]

  placement = {
    availability_zone = "eu-west-1a"
  }

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { WhatAmI = "Instance" }
    },
    {
      resource_type = "volume"
      tags          = { WhatAmI = "Volume" }
    },
  
  ]

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "megasecret"
      propagate_at_launch = true
    },
  ]

  tags_as_map = {
    extra_tag1 = "extra_value1"
    extra_tag2 = "extra_value2"
  }
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "and-loadbalancer"

  load_balancer_type = "application"

  vpc_id             = module.vpc.vpc_id
  subnets            = module.vpc.public_subnets
  security_groups    = [module.vpc.default_security_group_id]
  

  # access_logs = {
  #   bucket = "my-alb-logs"
  # }

  target_groups = [
    {
      name_prefix      = "pref-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
      targets = [
        {
          target_id = "i-022d867358fa0ec93"
          port = 80
        },
        {
          target_id = "i-011fcb73baf867788"
          port = 80
        }
      ]
    }
  ]

  https_listeners = [
    {
      port               = 443
      protocol           = "HTTPS"
      certificate_arn    = module.acm.acm_certificate_arn
      target_group_index = 0
    }
  ]

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = {
    Environment = "Test"
  }
}

# resource "aws_autoscaling_attachment" "alb_autoscale" {
#   alb_target_group_arn   = module.alb.target_group_arn
#   autoscaling_group_name = "${aws_autoscaling_group.autoscale_group.id}"
# }