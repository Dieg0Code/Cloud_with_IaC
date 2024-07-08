terraform {
  # Asume que el bucket S3 y la tabla DynamoDB ya existen
  backend "s3" {
    bucket = "terraform-remote-state-2024" # Nombre del bucket creado en AWS
    key = "web-app/terraform.tfstate" # Nombre del archivo de estado
    region = "sa-east-1" # Región donde se encuentra el bucket - LATAM
    dynamodb_table = "terraform-state-locking" # Nombre de la tabla DynamoDB
    encrypt = true # Encriptar el archivo de estado
  }


  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.57.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "instance 1" {
    ami = "ami-080111c1449900431" # Ubuntu 20.04 LTS - sa-east-1
    instance_type = "t2.micro"
    security_groups = [aws_security_group.insances.name]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World 1" > index.html
        python3 -m http.server 8080 &
    EOF
  
}

resource "aws_instance" "instance 2" {
    ami = "ami-080111c1449900431" # Ubuntu 20.04 LTS - sa-east-1
    instance_type = "t2.micro"
    security_groups = [aws_security_group.insances.name]
    user_data = <<-EOF
        #!/bin/bash
        echo "Hello, World 2" > index.html
        python3 -m http.server 8080 &
    EOF
  
}

resource "aws_s3_bucket" "bucket" {
  bucket = "terraform-remote-state-2024"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = "Enabled"
  }
  
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
  
}

# data se usa para usar recursos que ya existen en AWS, en este caso usamos el VPC por defecto que se crea
# con la cuenta de AWS
data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnets" {
  vpc_id = data.aws_vpc.default_vpc.id
}

resource "aws_security_group" "instances" {
  name = "instance-security-group"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.instances.id

  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"] # Cualquier IP puede acceder al puerto 8080
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.load_balancer_arn
  port = 80
  protocol = "HTTP"

  #Por defecto, devuelve una página de error 404
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code = "404"
    }
  }
}

resource "aws_lb_target_group" "intances" {
  name = "example-target-group"
  port = 8080
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default_vpc.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15 # Cada 15 segundos
    timeout = 3 # Timeout de 3 segundos
    healthy_threshold = 2 # 2 veces consecutivas
    unhealthy_threshold = 2 # 2 veces consecutivas
  }
}

resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.intances.arn
  target_id = aws_instance.instance_1.id
  port = 8080
}

resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.intances.arn
  target_id = aws_instance.instance_2.id
  port = 8080
}

resource "aws_lb_listener_rule" "instances" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.intances.arn
  }
}

# Security group para el balanceador de carga
resource "aws_security_group" "alb" {
  name = "alb-security-group"
}

resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "load_balancer" {
  name = "web-app-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default_subnets.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_route53_zone" "primary" {
  name = "example.com"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.primary.zone_id
  name = "example.com"
  type = "A"

  alias {
    name = aws_lb.load_balancer.dns_name
    zone_id = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  storage_type = "standard"
  engine = "postgres"
  engine_version = "12.5"
  instance_class = "db.t2.micro"
  db_name = "mydb"
  username = "myuser"
  password = "password"
  skip_final_snapshot = true
}