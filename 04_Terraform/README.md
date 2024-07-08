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

En este ejemplo necesitamos 5 recursos de AWS:

- Amazon Route 53
- Elastic load balancer
- Amazon EC2 (dos instancias)
- Amazon Simple Storage Service (S3)
- Amazon RDS

Todos estos recursos se pueden definir en un archivo de configuración de Terraform.

#### Storage del backend y Proveedores requeridos

```hcl
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
```

En este bloque estamos definiendo en donde se va a guardar el archivo de estado, asumimos que los recursos en donde se guardará ya fueron creados. Ademas establecemos el proveedor que se va a usar `AWS` en la versión `5.57.0`.

#### Configuración del proveedor y Creación de las instancias EC2

```hcl
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
```

- Configuramos el proveedor de AWS en la región `sa-east-1`, que seria los servidores para LATAM, el centro de datos está en Sao Paulo, Brasil.
- Creamos dos instancias EC2, una para cada servidor, con ``ami (Amazon Machine Image)`` de Ubuntu 20.04 LTS, tipo de instancia `t2.micro`, un grupo de seguridad y un script de inicio.
- El script de inicio crea un archivo `index.html` con un mensaje y levanta un servidor web en el puerto 8080.

#### Creación y configuración de el Bucket S3

```hcl
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
```

- Creamos la instancia del Bucket y la nombramos `terraform-remote-state-2024`.
- Habilitamos la versión del bucket. Esto se usa para mantener un historial de versiones de los archivos almacenados en el bucket.
- Configuramos la encriptación del bucket. Esto se usa para encriptar los archivos almacenados en el bucket, lo cual es recomendado.

#### Creación y configuración del VPC (Virtual Private Cloud)

```hcl
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
```

- Usamos `data` para usar recursos que ya está creados, en este caso usamos el VPC por defecto que se crea con la cuenta de AWS.
- Usamos `data` para obtener los IDs de las subredes por defecto del VPC.
- Creamos un grupo de seguridad para las instancias EC2.
- Creamos una regla de seguridad para permitir el tráfico HTTP en el puerto 8080.
- La regla permite que cualquier IP acceda al puerto 8080.

#### Load Balancer Config

```hcl
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
```

- Creamos un listener para el Load Balancer.
- El listener escucha en el puerto 80 y protocolo HTTP.
- Configuramos una acción por defecto para el listener. En este caso, si no se encuentra la página solicitada, se devuelve un error 404.

```hcl
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
```

- Creamos un target group para el Load Balancer. Un target group es un grupo de instancias que reciben tráfico del Load Balancer, en este caso, las instancias EC2.
- El target group escucha en el puerto 8080 y protocolo HTTP.
- Con `vpn_id` especificamos el VPC en el que se encuentra el target group.
- Configuramos un health check para el target group. El health check verifica que las instancias estén saludables y respondan correctamente al tráfico. Cada una de las propiedades del health check se explican en los comentarios.

```hcl
resource "aws_lb_target_group_attachment" "instance_1" {
  target_group_arn = aws_lb_target_group.intances.arn
  target_id = aws_instance.instance_1.id
  port = 8080
}
```

- Creamos un attachment para el target group. Un attachment es una relación entre el target group y una instancia EC2.
- El attachment especifica que la instancia `instance_1` es parte del target group `intances` y recibe tráfico del Load Balancer en el puerto 8080.

```hcl
resource "aws_lb_target_group_attachment" "instance_2" {
  target_group_arn = aws_lb_target_group.intances.arn
  target_id = aws_instance.instance_2.id
  port = 8080
}
```

- Creamos un attachment para la segunda instancia EC2.
- El attachment especifica que la instancia `instance_2` es parte del target group `intances` y recibe tráfico del Load Balancer en el puerto 8080.

```hcl
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
```

- Creamos una regla para el listener. Una regla especifica cómo se enruta el tráfico del listener al target group.
- Se establece la condición de la regla. En este caso, la regla se aplica a todas las rutas.
- Se establece la acción de la regla. En este caso, el tráfico se reenvía al target group `intances`. Osea todas las rutas son redirigidas a las instancias EC2.

#### Security group para el Load Balancer

```hcl
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
```

- Creamos un grupo de seguridad para el Load Balancer.
- Creamos una regla de seguridad para permitir el tráfico HTTP en el puerto 80.
- La regla permite que cualquier IP acceda al puerto 80.

#### Creación del Load Balancer

```hcl
resource "aws_lb" "load_balancer" {
  name = "web-app-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default_subnets.ids
  security_groups = [aws_security_group.alb.id]
}
```

- Creamos el Load Balancer.
- El Load Balancer se llama `web-app-lb`.
- El Load Balancer es de tipo `application`. Esto significa que el Load Balancer enruta el tráfico basado en la capa de aplicación, como la URL o el contenido de la solicitud.
- Con `subnets` especificamos las subredes en las que se encuentra el Load Balancer.
- Con `security_groups` especificamos el grupo de seguridad del Load Balancer. El cual fue creado anteriormente.

#### Creación del Recurso Route 53

```hcl
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
```

- Creamos una zona de Route 53.
- La zona se llama `example.com`.
- Creamos un registro de Route 53. Un registro es una entrada en la zona de Route 53 que se traduce en una dirección IP o un nombre de dominio.
- El registro se encuentra en la zona `primary`. La cual fue creada anteriormente.
- El registro se llama `example.com`.
- El tipo de registro es `A`. Esto significa que el registro se traduce en una dirección IP.
- Con `alias` especificamos que el registro se traduce en un alias. Un alias es una referencia a otro recurso de AWS, en este caso, el Load Balancer.
- Con `name` especificamos el nombre del alias. En este caso, el nombre del Load Balancer.
- Con `zone_id` especificamos la zona del alias. En este caso, la zona del Load Balancer.
- Con `evaluate_target_health` especificamos que Route 53 evalúa la salud del alias. Esto significa que Route 53 verifica que el alias esté disponible y responda correctamente al tráfico.
- Todo el tráfico que llegue a `example.com` será redirigido al Load Balancer.

#### Creación de la Base de Datos RDS

```hcl
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
```

- Creamos una instancia de base de datos RDS.
- La instancia tiene un almacenamiento de 20 GB.
- El tipo de almacenamiento es `standard`. Esto significa que el almacenamiento es magnético.
- El motor de la base de datos es `postgres`.
- La versión del motor de la base de datos es `12.5`.
- La clase de instancia es `db.t2.micro`.
- Configuramos el nombre, el usuario y la contraseña de la base de datos.
- Con `skip_final_snapshot` especificamos que no se crea una instantánea final de la base de datos. Esto significa que cuando eliminamos la base de datos, no se crea una instantánea de la base de datos en donde se guarda una copia de la base de datos, esto se suele hacer por si acaso se necesita recuperar la base de datos.

### Resumen

Con este archivo de configuración, creamos los recursos y los configuramos para la aplicación.

Hay varias cosas que se pueden mejorar, como la configuración de la base de datos en donde estamos dejando las credenciales harcodeadas, lo cual no es seguro. También podemos crear una VPC especifica para la aplicación, en lugar de usar la VPC por defecto. También estamos permitiendo que el trafico se haga desde cualquier IP y en HTTP, en vez de HTTPS. Todo esto se puede mejorar en futuras iteraciones.