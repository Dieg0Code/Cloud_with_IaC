# Terraform

El uso básico de esta herramienta se puede resumir en los siguientes pasos:

- `terraform init`
- `terraform plan`
- `terraform apply`
- `terraform destroy`

Ese sería un flujo de trabajo básico para usar Terraform.

## Arquitectura de Terraform

La arquitectura de Terraform consiste en 4 elementos importantes:

1. Archivos de estado y de configuración.
2. Terraform core.
3. Terraform Providers.
4. Cloud Providers.

Los archivos de configuración establecen la información necesaria para que podamos trabajar con la herramienta, interactúan con el core el cual transforma nuestras configuraciones en un plan de ejecución, los providers toman esas instrucciones y las traducen a las APIs de los cloud providers.

### Providers

Terraform soporta multiples providers que pueden ser consultados en la [documentación oficial](https://registry.terraform.io/browse/providers). Entre los mas populares se encuentran:

- AWS
- Azure
- Google Cloud
- Alibaba Cloud
- Oracle Cloud

Entre muchos otros.

La forma en la que usamos los providers es declarándolos en nuestro archivo de configuración:

Por ejemplos con AWS:

```hcl
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.57.0"
    }
  }
}

provider "aws" {
  # Configuration options
}
```

Con Azure:

```hcl
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.111.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
}
```

Con GCP:

```hcl
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.36.0"
    }
  }
}

provider "google" {
  # Configuration options
}
```

Con Alibaba Cloud:

```hcl
terraform {
  required_providers {
    alicloud = {
      source = "aliyun/alicloud"
      version = "1.226.0"
    }
  }
}

provider "alicloud" {
  # Configuration options
}
```

O con Oracle Cloud:

```hcl
terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
      version = "6.1.0"
    }
  }
}

provider "oci" {
  # Configuration options
}
```

Existen multiple providers para diferentes servicios y productos, por lo que es importante revisar la documentación oficial para encontrar el que necesitamos.

### terraform init

Cuando ejecutamos este comando, Terraform descarga el provider que hemos declarado en nuestro archivo de configuración.

Por ejemplo:

```hcl
terraform {
    required_providers {
        aws = {
        source = "hashicorp/aws"
        version = "5.57.0"
        }
    }
}

provider "aws" {
    region = "us-west-2"
}
```

Al ejecutar `terraform init` Terraform descargará el provider de AWS en la versión 5.57.0 y lo pondrá en nuestro directorio de trabajo actual. Esto crea una carpeta llamada `.terraform` en la que se almacenan los plugins de los providers, con su respectiva versión y arquitectura necesaria.

Por ejemplo el arból de directorios se vería así:

```
.
├── .terraform
│   └── providers
│       └── registry.terraform.io
│           └── hashicorp
│               └── aws
│                   └── 5.57.0
│                       └── darwin_amd64
│                           └── terraform-provider-aws_v5.57.0_x5
├── .terraform.lock.hcl
└── main.tf
```

El archivo `.terraform.lock.hcl` es un archivo que contiene información sobre dependencias especificas de los providers que estamos usando.

Si estamos usando módulos, Terraform también descargará los módulos que estemos usando en nuestro archivo de configuración.

Por ejemplo si estamos usando un módulo de VPC de AWS:

```
.
├── .terraform
│   ├── modules
│   │   ├── modules.json
│   │   └── vpc
.    .   .
.    .   .
.    .   .
│  │     ├── main.tf
│  │     ├── outputs.tf
│  │     ├── variables.tf
│  │     ├── versions.tf
│  │     ├── vpc-endpoints.tf
│  │     └── vpc-flow-logs.tf
│  └── providers
│           └── registry.terraform.io
│               └── hashicorp
│                   └── aws
│                       └── 5.57.0
│                           └── darwin_amd64
│                               └── terraform-provider-aws_v5.57.0_x5
├── .terraform.lock.hcl
└── main.tf
```     

### State File

Un archivo de estado es la forma en la que Terraform representa el estado del mundo.

Es un archivo JSON que contiene información sobre cada recurso y su estado actual.

```json
{
    "version": 4,
    "terraform_version": "0.14.4",
    "serial": 5,
    "lineage": "ad1eb9b9-c9a3-e58c-e666-f1ea007e918d",
    "outputs": {},
    "resources": [
      {
        "mode": "managed",
        "type": "aws_instance",
        "name": "example",
        "provide": "provider[\"registry.terraform.io/hashicorp/aws\"]",
        "instances": [
          {
            "schema_version": 1,
            "attributes": {
              "ami": "ami-011899242bb902164",
              "arn": "arn:aws:ec2:us-east-1:917774925227:instance/i-0e9ac03f2e84f845b",
              "public_ip": "3.87.232.28",
              ...
              <more attributes>
              ...
            },
            "sensitive_attributes": [],
            "private": "..."
          }
        ]
      }
    ]
}
```

Este archivo de estado puede contener datos sensible como contraseñas para la base de datos, claves privadas, etc. Por lo que es importante mantenerlo seguro.

Puede ser almacenado localmente o remoto, por defecto Terraform lo almacena localmente en el directorio de trabajo actual. En ambientes de producción se suele almacenar por ejemplo en un bucket de S3, en Azure Blob Storage, en Google Cloud Storage, etc. Terraform también tiene soporte para almacenar el archivo de estado en un backend de Terraform Cloud.

Este archivo almacena información en texto plano, por lo que puede ser un target para posibles ataques.

### terraform plan

Este comando toma el estado deseado, el cual es el que nosotros definimos en nuestros archivos de configuración y lo compara con el estado actual. Es recomendable no hacer cambios por fuera de terraform, ya que esto puede causar problemas.

Por ejemplo, en nuestros archivos de configuración tenemos definidos una red, 4 servidores y una base de datos, pero a traves de la interfaz alguien ya desplegó estos servicios, la red, la base de datos idéntica, pero solo 3 servidores, Terraform hará la comparación y se dará cuenta de que falta desplegar un servidor extra, entonces definirá el plan, la secuencia de llamadas a la API de AWS necesarias para desplegar la infancia EC2 que falta, entonces con el comando `terraform apply` podríamos ejecutar el plan y desplegar el servidor faltante.

### terraform destroy

Este comando en su cometido es simple pero poderoso. Simplemente elimina todos los servicios desplegados para este proyecto en especifico.

### Remote Backend

Como se mencionaba anteriormente, podemos almacenar el archivo de estado de forma remota para mayor seguridad.

Por ejemplo en Terraform Cloud:

```hcl
terraform {
  backend "remote" {
    organization = "devops-directive"
    
    workspace {
      name = "terraform-course"
    }
  }
}
```

Este servicio es gratuito solo hasta para 5 usuarios.

Otra opción para almacenar esto podría ser AWS en un bucket S3:

```hcl
terraform {
  backend "s3" {
    bucket         = "devops-directive-tf-state"
    key            = "tf-infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }
}
```

El bucket S3 es en donde va a vivir el archivo, la tabla de `DynamoDB` es necesaria porque puede ser que varias personas trabajen en el mismo proyecto a la vez, entonces para prevenir que dos personas traten de aplicar diferentes cambios al mismo tiempo, usamos la garantía que nos ofrece Dynamo de que los cambios sean atómicos, osea que no se pueda aplicar un cambio hasta que el otro este listo.

Ejemplo de una configuración para trabajar un Backend remoto con AWS:

```hcl
terraform {
  required_provider {
    aws = {
      source = "hashicorp/aws
      version = "~>3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "devops-directive-tf-state"
  force_destroy = true
  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "terraform_locks" {
  name = "terraform-state-locking"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

En este ejemplo, configuramos que nuestro archivo de estado se almacene en un bucket de S3 y que se use una tabla de DynamoDB para el bloqueo de estado.

Podemos hacer lo mismo, pero especificando directamente a Terraform que nuestro archivo de estado se guardará en un bucket s3

```hcl
terraform {
  backend "s3" {
    bucket = "devops-directive-tf-state"
    key = "tf-infra/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    encrypt = true
  }
}
```

El resto de la configuración seria la misma

Cuando ejecutemos `terraform init` Terraform nos preguntará si queremos migrar nuestro archivo de estado local al backend remoto, si decimos que si, Terraform se encargará de mover el archivo de estado al bucket de S3 y de configurar la tabla de DynamoDB.

## Ejemplo de Web App

![Web App](./assets/architecture.png)