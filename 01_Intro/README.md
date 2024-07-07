# Terraform

Según HashiCorp, la empresa creadora de terraform, Terraform es una herramienta para construir, cambiar y versionar infraestructura de forma segura e eficiente. Con Terraform podemos definir archivos de configuración que describen la infraestructura del proveedor cloud que escojamos, en un nivel mas abstracto, es una capa entre nosotros y el proveedor, la cual se encarga de desplegar la infraestructura que definimos en los archivos de configuración.

## Historia de sistemas Cloud

### Pre - Cloud

Entre los años 1990 y 2000, cuando tenias una idea para un software, no solo bastaba con programar dicha idea, si querías distribuir tu software a escala, tenia ademas que construir tu infraestructura, es decir, comprar servidores, routers, switches, encargarte de configurar la red, etc. Esto era un proceso muy largo y costoso.

### Post - Cloud

Esto cambió cuando surgieron los servicios cloud como Amazon Web Services (AWS), Google Cloud Platform (GCP), Microsoft Azure, etc. Estos servicios permiten a los desarrolladores alquilar infraestructura en la nube, para diversos propósitos, como almacenamiento, computo, bases de datos, etc. Esto permitió a los desarrolladores enfocarse en lo que realmente importa, que es el software, y no en la infraestructura.

Los servicios cloud permiten escalar la infraestructura de forma dinámica, es decir, si necesitamos mas recursos en cierto momento podemos crecer y luego cuando ya no los necesitemos podemos reducirlos.

## Aprovisionamiento de infraestructura

Para aprovisionar infraestructura en la nube, podemos hacerlo de tres formas:

1. **GUI (Graphical User Interface)**: Podemos ir a la consola del proveedor cloud y crear la infraestructura manualmente mediante una interfaz gráfica, es la forma mas básica de hacerlo ya que los proveedores cloud ofrecen una interfaz web para hacerlo.
2. **API/CLI**: Todos los principales proveedores cloud ofrecen una API para interactuar con sus servicios, también ofrecen una CLI (Command Line Interface) para interactuar con sus servicios mediante la terminal.
3. **Infraestructura como código (IaC)**: Esta es la forma mas avanzada de aprovisionar infraestructura en la nube, consiste en definir la infraestructura en archivos de configuración, los cuales describen la infraestructura que queremos desplegar, y luego con una herramienta como Terraform, desplegar dicha infraestructura.

## Infraestructura como código (IaC)

La infraestructura como código (IaC) es una forma de aprovisionar infraestructura en la nube mediante archivos de configuración que usan un lenguaje de dominio, en el caso de Terraform, el lenguaje de dominio es HCL (HashiCorp Configuration Language). Este lenguaje nos permite declarar la infraestructura que queremos desplegar, servicios como EC2 para instancias de servidores, S3 para almacenamiento, RDS para bases de datos, etc. Nosotros declaramos lo que queremos y Terraform se encarga de desplegarlo.

Hacerlo de esta forma nos trae multiples ventajas, como:

- **Control de versiones**: Podemos versionar los archivos de configuración en un repositorio de git, lo que nos permite ver los cambios que se han hecho en la infraestructura a lo largo del tiempo y manipularlos colaborativamente.
- **Reusabilidad**: Podemos reutilizar módulos de infraestructura que ya han sido creados por la comunidad, o por nosotros mismos, para desplegar infraestructura de forma mas rápida.
- **Facilidad para desplegar y destruir infraestructura**: Podemos desplegar y destruir infraestructura de forma rápida y segura, sin tener que preocuparnos por configuraciones manuales. Todo con un solo comando.
- **Seguridad**: Podemos definir políticas de seguridad en los archivos de configuración, para que la infraestructura desplegada cumpla con ciertos estándares de seguridad.
- **Documentación**: Los archivos de configuración sirven como documentación de la infraestructura, ya que describen la infraestructura que se va a desplegar.
- **Automatización**: Podemos automatizar el despliegue de infraestructura mediante pipelines de CI/CD, para que cada vez que se haga un cambio en el repositorio de git, se despliegue automáticamente la infraestructura.
- **Multi-cloud**: Podemos desplegar infraestructura en múltiples proveedores cloud, ya que Terraform soporta múltiples proveedores cloud. Esto nos da la flexibilidad para no depender unicamente de un proveedor sino que podemos tener plan b, c o d. Ante cualquier imprevisto.
- **Cloud agnostic**: Podemos desplegar infraestructura en cualquier proveedor cloud, ya que Terraform es cloud agnostic, es decir, no esta atado a un proveedor en particular.
- **Costos**: Podemos estimar los costos de la infraestructura que vamos a desplegar, ya que Terraform nos muestra un plan de lo que se va a desplegar y cuanto nos va a costar.

Ejemplo simple de un archivo de configuración de Terraform:

```hcl
provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

En este ejemplo estamos declarando un proveedor de AWS y un recurso de instancia de EC2. Con este archivo de configuración, Terraform se encargará de desplegar una instancia de EC2 en la región `us-west-2` con la AMI (Amazon Machine Image) `ami-0c55b159cbfafe1f0` y el tipo de instancia `t2.micro`.

Mientras otras herramientas como `CloudFormation` de AWS, `Deployment Manager` de Google Cloud, `ARM Templates` de Azure, también permiten desplegar infraestructura como código, tiene la desventaja de estar atadas a sus respectivos proveedores cloud, mientras que Terraform es cloud agnostic, es decir, no esta atado a un proveedor en particular.

### Principales servicios de AWS

AWS no ofrece un amplio rango de servicios para todo tipo de necesidades, los servicios son aproximadamente 200, pero algunos de los mas usados, siempre son servicios para bases de datos, almacenamiento de archivos, almacenamiento de contenedores, ejecución de contenedores, servicios de computo, servicios de monitoreo, entre otros.

Los mas usados son:

- ``EC2 (Elastic Compute Cloud)``: Servicio de computo. Es un servidor de toda la vida, este servicio nos permite desplegar una instancia de un servidor virtual, como puede ser Ubuntu, el cual es usado común mente para desplegar aplicaciones web, ya sean front-end o back-end. Es una buena opción para aplicaciones monolíticas o si necesitas más control sobre la infraestructura.
- ``S3 (Simple Storage Service)``: Servicio de almacenamiento de objetos. Es un servicio que nos permite almacenar archivos de cualquier extenso, JPG, PNG, PDF, etc. Es muy usado para almacenar archivos estáticos de una aplicación web, como imágenes, videos, etc. No solo es útil para archivos estáticos, sino también para backups y almacenamiento de datos no estructurados.
- ``RDS (Relational Database Service)``: Servicio de bases de datos relacionales. Es un servicio que nos permite desplegar bases de datos relacionales como MySQL, PostgreSQL, Oracle, etc. Es usado como capa de persistencia de una aplicación.
- ``Lambda``: Servicio de computo sin servidor. Es un servicio que nos permite ejecutar código sin tener que preocuparnos por la infraestructura, almacenamos en el servicio el código que queremos ejecutar y con cada petición que se haga al servicio, se ejecuta el código, no tenemos que desplegar servidores, preocuparnos de configurar la red, etc. Simplemente subimos el código y el servicio se encarga de ejecutarlo cada vez que se haga una petición. Comúnmente usado para ejecutar código de forma asíncrona, como enviar un email, procesar una imagen, etc. Incluso se puede usar como un backend completo de una aplicación. Muy útil para tareas event-driven y cuando necesitas escalar sin preocuparte por la infraestructura.
- ``ECS (Elastic Container Service)``: Servicio de contenedores. Es un servicio que nos permite desplegar contenedores de Docker en la nube. Es usado para desplegar aplicaciones empaquetadas en contenedores de Docker.
- ``ECR (Elastic Container Registry)``: Servicio de registro de contenedores. Es un servicio que nos permite almacenar imágenes de contenedores de Docker. Es usado para almacenar las imágenes de contenedores de Docker que vamos a desplegar en ECS.
- ``EKS (Elastic Kubernetes Service)``: Servicio de Kubernetes. Es un servicio que nos permite desplegar clusters de Kubernetes en la nube. Es usado para desplegar aplicaciones empaquetadas en contenedores de Docker, pero con la orquestación de Kubernetes.
- ``CloudWatch``: Servicio de monitoreo. Es un servicio que nos permite monitorear la infraestructura en la nube, como logs, métricas, alarmas, etc. Es usado para monitorear la infraestructura y aplicaciones en la nube.
- ``IAM``: Servicio de gestión de identidad y acceso. Es un servicio que nos permite gestionar los usuarios y permisos de la infraestructura en la nube. Es usado para dar permisos a los usuarios para que puedan interactuar con los servicios de AWS.
- ``VPC (Virtual Private Cloud)``: Servicio de red. Es un servicio que nos permite crear una red privada virtual en la nube. Es usado para aislar la infraestructura en la nube y definir reglas de acceso a la red.
- ``Route 53``: Servicio de DNS. Es un servicio que nos permite gestionar los dominios y subdominios de una aplicación. Es usado para redirigir el tráfico de un dominio a la infraestructura en la nube. También ofrece enrutamiento basado en latencia y failover, además de la gestión de dominios.
- ``CloudFront``: Servicio de CDN. Es un servicio que nos permite distribuir contenido estático de una aplicación en servidores distribuidos en todo el mundo. Es usado para mejorar la velocidad de carga de una aplicación.

Entre muchos otros, como mencionaba anteriormente, son mas de 200 servicios los que ofrece AWS. Estos son los mas usados comúnmente.

### Ejemplo de aplicación web simple

Por ejemplo, tenemos una aplicación web, con su respectivo frontend y backend, para desplegar y distribuirla necesitaríamos los siguientes servicios:

- **EC2**: Para desplegar el frontend y backend de la aplicación.
- **S3**: Para almacenar los archivos estáticos de la aplicación, como imágenes, videos, etc.
- **RDS**: Para almacenar la base de datos de la aplicación.
- **Lambda**: Para ejecutar código asíncrono, como enviar un email, procesar una imagen, etc.
- **Route 53**: Para gestionar el dominio de la aplicación.

Eso como mínimo, podríamos reemplazar el ``EC2`` por ``ECS`` si la aplicación esta empaquetada en contenedores de Docker o si el backend esta construido bajo una arquitectura de microservicios lo desplegamos en `EKS`.

### Ejemplo 2 - Blog Personal

Para una aplicación como un blog personal, pero que queremos que sea mas robusta a nivel de infraestructura, podríamos necesitar los siguientes servicios:

- **EC2**: Para desplegar el backend de la aplicación (API RESTful) y el frontend (React, Vue.js, etc.).
- **S3**: Para almacenar archivos estáticos del frontend y archivos subidos por los usuarios.
- **RDS**: Para almacenar los datos del blog, como posts, comentarios y usuarios.
- **Lambda**: Para tareas como el procesamiento de imágenes subidas o el envío de correos electrónicos de notificación.
- **Route 53**: Para gestionar el dominio del blog.
- **CloudFront**: Para distribuir los archivos estáticos del S3 globalmente con baja latencia.
- **IAM**: Para gestionar permisos y roles de acceso a los servicios.
- **VPC**: Para aislar la red y proteger las instancias y bases de datos.
- **CloudWatch**: Para monitorear la aplicación y recibir alertas sobre el rendimiento o problemas.
- **ELB**: Para distribuir el tráfico entre múltiples instancias EC2 para mejorar la disponibilidad y escalabilidad.
- **Secrets Manager**: Para gestionar de manera segura las credenciales de la base de datos y otros secretos.
- **SNS**: Para enviar notificaciones a los administradores del blog sobre nuevos comentarios o usuarios registrados.
- **SQS**: Para gestionar colas de mensajes entre diferentes microservicios, como el procesamiento de comentarios o la generación de informes.
- **Cognito**: Para manejar la autenticación de usuarios y permitirles iniciar sesión con proveedores de identidad externos como Google o Facebook.

Este seria un ejemplo de una aplicación simple, pero bien construida a nivel de infraestructura, en donde aprovechamos varios de los servicios ofrecidos por AWS. Las decisiones de arquitectura y servicios a utilizar dependerán de las necesidades de la aplicación y los recursos disponibles. Hay que recordar que AWS nos cobrará por el uso de sus servicios, quizás si queremos ahorrar costos vamos a tener que simplificar la arquitectura, tal vez una aplicación simple como un blog no necesite tantos servicios, como CloudFront, ELB, Secrets Manager, SNS, SQS, Cognito, etc. Recordar que es un ejemplo para ilustrar la amplia gama de servicios que ofrece AWS.

### Terraform y como entra en todo esto

En nuestros dos ejemplos anteriores necesitamos varios servicios para cada proyecto, para configurar y desplegar cada uno lo normal o básico sería entrar a la consola y mediante la GUI desplegar y configurar cada servicio, pero esto sería tedioso y propenso a errores, si bien el propósito de un GUI es facilitar la interacción, puede ser confusa y laberíntica, además de que es lento hacerlo así, poco reproducible, difícil de modificar, no es escalable y no es seguro.

Otra opción que tenemos es usar el CLI de AWS, si bien esto es mas automatizable, tiene los mismos problemas que la GUI, es lento, poco reproducible, difícil de modificar, no es escalable y no es seguro.

Terraform soluciona estos problemas, como programador sabemos el poder que tiene definir las cosas en código, es fácil de entender, reproducible, escalable, seguro, fácil de modificar, etc. Es ágil, ese es el concepto clave, todas las personas que tienen entendimiento de la herramienta pueden leer las especificaciones y entender la arquitectura de la infraestructura, lo cual te da una visión general del sistema. Con un comando desplegamos todos los servicios, es un paso, comparado con lo que sería ir a la GUI y hacerlo desde ahí que serían varios pasos. Si queremos migrar de Cloud porque otro proveedor es mas barato, lo podemos hacer sin demasiado esfuerzo, incluso podemos escoger diversos servicios de diferentes proveedores para optimizar costes, quizás una `Lambda` de AWS es mas barata que una `Cloud Function` de Google Cloud, entonces podemos escoger, Terraform nos da esa flexibilidad.

#### Ejemplo 1 en Terraform

```hcl
provider "aws" {
  region = "us-west-2"
}

# Crear una VPC para aislar nuestra red y mejorar la seguridad
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Crear una Subnet dentro de la VPC
resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
}

# Crear un Security Group para controlar el tráfico de red
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  # Permitir tráfico HTTP (puerto 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir tráfico HTTPS (puerto 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir todo el tráfico de salida
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Crear una instancia EC2 para el frontend
resource "aws_instance" "frontend" {
  ami             = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "frontend"
  }
}

# Crear una instancia EC2 para el backend
resource "aws_instance" "backend" {
  ami             = "ami-0c55b159cbfafe1f0"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "backend"
  }
}

# Crear un bucket S3 para almacenar archivos estáticos
resource "aws_s3_bucket" "static_files" {
  bucket = "myapp-static-files"
  acl    = "public-read" # Hacer que los archivos sean accesibles públicamente

  website {
    index_document = "index.html" # Definir el documento de índice para el sitio web
  }
}

# Crear una instancia RDS para la base de datos
resource "aws_db_instance" "default" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t2.micro"
  name                 = "mydatabase"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  skip_final_snapshot  = true

  vpc_security_group_ids = [aws_security_group.web_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.default.name
}

# Crear un grupo de subredes para la base de datos
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.main.id]
}

# Crear una función Lambda para tareas asíncronas
resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda_function.zip" # Archivo ZIP con el código de la función
  function_name    = "my_lambda_function"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs12.x"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# Crear una política IAM para la función Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Adjuntar la política de ejecución básica de Lambda al rol IAM
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Crear una zona de Route 53 para gestionar el dominio
resource "aws_route53_zone" "main" {
  name = "myapp.com"
}

# Crear un registro DNS para el frontend
resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www"
  type    = "A"
  ttl     = "300"

  records = [aws_instance.frontend.public_ip]
}

# Crear un registro DNS para el backend
resource "aws_route53_record" "backend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api"
  type    = "A"
  ttl     = "300"

  records = [aws_instance.backend.public_ip]
}
```

Este es un ejemplo simple de un archivo de configuración de Terraform, en donde estamos declarando varios recursos de AWS, como una VPC, subredes, instancias EC2, buckets S3, instancias RDS, funciones Lambda, zonas de Route 53, etc. Con este archivo de configuración, Terraform se encargará de desplegar toda la infraestructura en AWS.

### Ejemplo 2 en Terraform

```hcl
# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  default = "10.0.2.0/24"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main_vpc"
  }
}

# Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name = "private_subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main_igw"
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

# Security groups
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Security group for web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web_sg"
  }
}

# EC2 instances
resource "aws_instance" "backend" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = aws_key_pair.my_key.key_name

  tags = {
    Name = "backend"
  }
}

resource "aws_instance" "frontend" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  key_name      = aws_key_pair.my_key.key_name

  tags = {
    Name = "frontend"
  }
}

# S3 bucket
resource "aws_s3_bucket" "static_files" {
  bucket = "my-blog-static-files-${random_string.bucket_suffix.result}"

  tags = {
    Name = "static_files"
  }
}

resource "aws_s3_bucket_public_access_block" "static_files" {
  bucket = aws_s3_bucket.static_files.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# RDS instance
resource "aws_db_instance" "blog_db" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "blogdb"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  tags = {
    Name = "blog_db"
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.public_subnet.id]

  tags = {
    Name = "main_db_subnet_group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "db_sg"
  description = "Security group for database"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  tags = {
    Name = "db_sg"
  }
}

# Lambda function
resource "aws_lambda_function" "image_processing" {
  filename         = "image_processing.zip"
  function_name    = "image_processing"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
  source_code_hash = filebase64sha256("image_processing.zip")

  tags = {
    Name = "image_processing_lambda"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "lambda_exec_role"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Route 53
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "main_zone"
  }
}

resource "aws_route53_record" "frontend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "backend" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.main.dns_name
    zone_id                = aws_lb.main.zone_id
    evaluate_target_health = true
  }
}

# CloudFront distribution
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.static_files.bucket_regional_domain_name
    origin_id   = "s3-static-files"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "s3-static-files"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD", "OPTIONS"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.cert.arn
    ssl_support_method  = "sni-only"
  }

  tags = {
    Name = "s3_distribution"
  }
}

resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "main-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.private_subnet.id]

  tags = {
    Name = "main_lb"
  }
}

resource "aws_lb_target_group" "backend" {
  name     = "backend-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.cert.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# CloudWatch
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/aws/app/logs"
  retention_in_days = 30

  tags = {
    Name = "app_log_group"
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "HighCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  dimensions = {
    InstanceId = aws_instance.backend.id
  }

  tags = {
    Name = "cpu_alarm"
  }
}

# SNS Topic
resource "aws_sns_topic" "alerts" {
  name = "app_alerts"

  tags = {
    Name = "alerts_topic"
  }
}

# SQS Queue
resource "aws_sqs_queue" "app_queue" {
  name = "app_queue"

  tags = {
    Name = "app_queue"
  }
}

# Cognito
resource "aws_cognito_user_pool" "user_pool" {
  name = "user_pool"

  password_policy {
    minimum_length    = 8
    require_uppercase = true
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
  }

  tags = {
    Name = "user_pool"
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  name         = "user_pool_client"
  user_pool_id = aws_cognito_user_pool.user_pool.id

  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "db_credentials"

  tags = {
    Name = "db_credentials_secret"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# Data sources
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Key pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# ACM Certificate
resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = {
    Name = "main_cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Variables
variable "domain_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}
```

Este es un ejemplo mas avanzado de un archivo de configuración de Terraform, en donde estamos declarando varios recursos de AWS, como una VPC, subredes, instancias EC2, buckets S3, instancias RDS, funciones Lambda, zonas de Route 53, CloudFront, Load Balancer, CloudWatch, SNS, SQS, Cognito, Secrets Manager, etc.

Como tal los archivos de configuración de terraform pueden crecer mucho, en tamaño y en complejidad, pero esto se puede mitigar con el uso de módulos, terraform no da esa posibilidad, por ejemplo, podríamos tener un módulo para la VPC, otro para las subredes, otro para las instancias EC2, otro para los buckets S3, etc. De esta forma podemos reutilizar código y simplificar los archivos de configuración.

Podemos separar los módulos por carpetas o usar la función de módulos de Terraform, la cual nos permite definir módulos en archivos separados y luego llamarlos desde el archivo principal de configuración.