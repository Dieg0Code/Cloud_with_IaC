# Ejemplo de Web App

![Web App](../assets/architecture.png)

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