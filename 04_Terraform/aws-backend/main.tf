terraform {
  ####################################################################
  ## DESPUES EJECUTAR: terraform apply (CON BACEKND LOCAL)          ##
  ## DESCOMENTAR ESTA SECCIÓN Y EJECUTAR NUEVAMENTE terraform init  ##
  ## PARA CAMBIAR DE UN BACKEND LOCAL A UN BACKEND REMOTO EN AWS    ##
  ####################################################################
    # backend "s3" {
    #     bucket = "terraform-remote-state-2024" # Nombre del bucket creado en AWS
    #     key    = "web-app/terraform.tfstate" # Nombre del archivo de estado
    #     region = "sa-east-1" # Región donde se encuentra el bucket - LATAM
    #     dynamodb_table = "terraform-state-locking" # Nombre de la tabla DynamoDB
    #     encrypt = true # Encriptar el archivo de estado
    # }

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

resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-remote-state-2024" # Bucket name
    force_destroy = true
}

# Versioning y encriptación ahora se definen así, como recursos

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
      status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state_encryption" {
    bucket = aws_s3_bucket.terraform_state.bucket.id

    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
}

resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform-state-locking"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
      name = "LockID"
      type = "5"
    } 
}