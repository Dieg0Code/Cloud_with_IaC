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

## Variables y Outputs

Muchas cosas pueden ser parametrizadas en Terraform, por ejemplo, podemos parametrizar el nombre de una instancia EC2, el tamaño de una base de datos, el nombre de un bucket de S3, etc. Las variables son útiles para no hardcodear datos sensibles en nuestros archivos de configuración como contraseñas, claves privadas, etc.

### Tipos de Variables

- Input Variables
  - `var`.\<name>

  ```hcl
  variable "instance_type" {
    description = "ec2 instance type"
    type = string
    default = "t2.micro"
  }
  ```

  Este tipo de variables nos permiten escoger de manera dinámica valores para nuestros recursos mediante el input del usuario.

- Local variables
  - `local`.\<name>

  ```hcl
  locals {
    service_name = "my-service"
    owner = "owner"
  }
  ```

  Este tipo de variables tienen un scope local como el de una función por ejemplo, se usan para definir valores que se van a usar en multiples recursos, de esta forma los centralizamos en un solo lugar y así evitamos tener que escribir el valor cada vez.

- Output Variables
  - `output`.\<name>

  ```hcl
  output "instance_ip_addr" {
    value = aws_instance.example.public_ip
  }
  ```

  Este tipo de variables son como un `return` en un lenguaje de programación, nos permiten devolver valores de nuestros recursos para que puedan ser capturados y usados posteriormente.

### Configuración de Input Variables

- Ingreso manual durante la ejecución de los comandos `apply` o `plan`

```bash
terraform apply -var 'instance_type=t2.large'
```

- Valores por defecto en un bloque de declaración de variables

```hcl
variable "instance_type" {
  description = "ec2 instance type"
  type = string
  default = "t2.micro"
}
```

- TF_VAR_\<name> variables de entorno

```bash
export TF_VAR_instance_type=t2.large
```

```cmd
set TF_VAR_instance_type=t2.large
```

- terraform.tfvars file

```hcl
instance_type = "t2.large"
```

- *.auto.tfvars file

```hcl
instance_type = "t2.large"
```

- Linea de comandos `-var` o `-var-file`

```bash
terraform apply -var-file="example.tfvars"
```

### Tipos y Validación

#### Tipos Primitivos

- string
- number
- bool

#### Tipos Complejos

- list(\<TYPE>)
- set(\<TYPE>)
- map(\<TYPE>)
- object({\<ATTR NAME> = \<TYPE>, ...})
- tuple([\<TYPE>, ...])

#### Validación

- La comprobación de tipos ocurre automáticamente
- Se pueden configurar condiciones personalizadas

```hcl
variable "instance_type" {
  description = "ec2 instance type"
  type = string
  default = "t2.micro"
  validation {
    condition = length(var.instance_type) > 0
    error_message = "The instance type must not be empty"
  }
}
```

### Datos Sensibles

**Podemos marcar variables como sensibles**.

- Sensitive = true

```bash
Terraform will perform the following actions

# some_resource.a will be created
+ resource "some_resource" "a" {
  + sensitive_value = (sensitive)
}
```

**Pasarle variables de entorno al comando `apply`.

- TF_VAR_variable
- `-var` (recuperada desde el secret manager en tiempo de ejecución)

**También se puede usar un secret store externo**

- Por ejemplo, AWS Secrets Manager

## Features adicionales del lenguaje

### Expresiones

- Template strings
- Operadores (!, -, +, *, /, %, >, ==, etc)
- Condicionales (conditional ? true : false)
- For ([ for o in var.list : o.id ])
- Splat (var.list[*].id)
- Dynamic Blocks
- Constraints (Type & Version)

### Funciones

- Numéricas
- String
- Collections
- Encoding
- Filesystem
- Date & Time
- Hash & Crypto
- IP Network
- Type Conversion

### Meta-Arguments

#### depends_on

- Terraform genera automáticamente un grafo de dependencias basado en referencias.

- Si dos recursos dependen uno del otro (pero no de alguna otra cosa), *depends_on* especifica esa dependencia para reforzar el orden de creación.

```hcl
resource "aws_iam_role" "example" {
  name = "example"
  assume_role_policy = "..."
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.example.name
}

resource "aws_iam_role_policy" "example" {
  name = "example"
  role = aws_iam_role.example.name
  policy = jsonencode({
    "Statement" = [{
      "Action" = "s3:*",
      "Effect" = "Allow",
    }],
  })
}

resource "aws_instance" "example" {
  ami = "ami-abc123"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.example

  depends_on = [
    aws_iam_role_policy.example,
  ]
}
```

- Por ejemplo, si el software en una instancia necesita acceso a un bucket S3, la creación de esa instancia fallará si se hace antes de crear el *aws_iam_role_policy*, por lo que podemos especificar a Terraform que la creación de esa instancia depende de que primero se cree el *aws_iam_role_policy*

#### Count

- Permite la creación de multiples resources/modules desde un solo bloque de código.

- Es útil cuando multiples recursos son necesarios pero son prácticamente idénticos.

```hcl
resource "aws_instance" "server" {
  count = 4 # crea cuatro instancias EC2

  ami = "ami-abc1234"
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index}"
  }
}
```

#### for_each

- Permite la creación de múltiples resources/modules desde un solo bloque de código.

- Permite más control para customizar cada recurso que **count**

```hcl
locals {
  subnet_ids = toset([
    "subnet-abcde",
    "subnet-012345",
  ])
}

resource  "aws_instance" "server" {
  for_each = local.subnet_ids

  ami = "ami-a1b2c3d4"
  instance_type = "t2.micro"
  subnet_id = each.key

  tags = {
    Name = "Server ${each.key}"
  }
}
```

#### Lifecycle

- Un conjunto de meta-argumentos para controlar el comportamiento de Terraform para recursos específicos.

- *create_before_destroy* es útil para despliegues con cero *downtime*.

- *ignore_changes* previene que Terraform trate de revertir cambios que fueron declarados por fuera.

- *prevent_destroy* hace que Terraform rechace cualquier plan que podría destruir alguno de los recursos actuales.

```hcl
resource "aws_instance" "example" {
  ami = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      # Some resources have metadata
      # modified automatically outside
      # of Terraform
      tags
    ]
  }
}
```

### Provisioners

Ejecutan acciones en maquinas locales o remotas.

- Ansible
- Chef
- Puppet

Si bien, Terraform se encarga de crear los recursos, estos necesitan ser configurados, necesitan dependencias y configuraciones variadas para poder ejecutar el Software que se planea delegar en estos. Los **Provisioners** se encargan de automatizar esto.

## Organización del Proyecto - Módulos

Un módulo es un contenedor para múltiples recursos que son usados en conjunto. Un módulo consiste en una serie de archivos `.tf` y/o `tf.json` que son almacenados juntos en un directorio.

Los módulos son la forma principal de empaquetar y re-usar recursos configurados con Terraform.

### Tipos de Módulos

- `Root Module`: Por defecto contiene todos los archivos **.tf* en el directorio de trabajo principal.
- `Child Module`: Un módulo separado que es usado en algún archivo **.tf** del modulo Root.

Estos módulos pueden venir desde una variedad de fuentes:

- Locales

```hcl
module "web-app" {
  source = ".../web-app"
}
```

- Terraform Registry

```hcl
module "consul" {
  source = "hashicorp/consul/aws"
  version = "0.1.0"
}
```

- GitHub

```hcl
# HTTPS
modules "example" {
  source = "github.com/hashicorp/example?ref=v1.2.0"
}

# SSH
module "example" {
  source = "git@github.com:hashicorp/example.git"
}

# Generic
module "example" {
  source = "git::ssh://username@example.com/storage.git"
}
```

- Bitbucket
- Git, Mercurial, etc.
- HTTP URLs
- S3 buckets
- GCS buckets

### Inputs + Meta-arguments

- Inputs variables son pasadas en el bloque de código.

```hcl
module "web-app" {
  source = ".../web-app-module"

  # Input Variables
  bucket_name = "example-bucket-web-app-data"
  domain = "example.com"
  db_name = "mydb"
  db_user = "user"
  db_pass = var.db_pass
}
```

#### Meta-arguments

- count
- for_each
- providers
- depends_on

### Como se ve un buen Módulo

- Eleva el nivel de abstracción de los tipos de recursos básicos.

- Agrupa los recursos de forma lógica.

- Expone inputs variables que permiten la customización necesaria.

- Provee defaults útiles.

- Devuelve outputs para que posibles integraciones futuras sean más fáciles.

### Terraform Registry

Contiene todos lo módulos disponibles de Terraform, son un conjunto de recursos pre configurados que podemos usar.

## Trabajando con Múltiples Entornos

En los entornos de trabajo actuales, es común teener multiples entornos de trabajo, por ejemplo:

- Desarrollo
- Staging
- Producción

En donde cada uno de estos entornos tiene sus propias configuraciones, recursos, etc.

### Dos Enfoques Principales

#### Workspaces

- Multiples entornos con nombre con un mismo backend.

```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

```bash
terraform workspace list
```

Terraform nos brinda una forma para trabajar con múltiples entornos mediante el comando `terraform workspace`, este comando nos permite crear, listar y seleccionar diferentes entornos de trabajo.

#### File Structure

- Separación de ambientes por directorios.

```bash
.
├── _modules
│   ├── module-1
│   │    └── main.tf
│   │    └── variables.tf
│   └── module-2
│        └── main.tf
│        └── variables.tf
├── dev
│   ├── main.tf
│   └── terraform.tfvars
├── staging
│   ├── main.tf
│   └── terraform.tfvars
└── prod
    ├── main.tf
    └── terraform.tfvars
```

En este enfoque, separamos los ambientes de trabajo en diferentes directorios, cada uno con sus propios archivos de configuración, variables, etc.

### Pros y Contras

#### Workspaces

- Pros
  - Fácil de usar
  - *terraform.workspace* variable
  - Minimiza la duplicación del código
- Contras
  - Propenso a error humano
  - El estado es almacenado en el mismo backend
  - Es difícil saber en que ambiente se está trabajando con solo ver el código

#### File Structure

- Pros
  - Separación de los backends
  - Seguridad mejorada
  - Reduce el riesgo de error humano
  - El código representa bien el estado de los despliegues
- Contras
  - Hay que ejecutar `terraform apply` múltiples veces
  - Mas duplicación de código.

### File Structure (environments  + componentes)

- Mayor separación (componentes separados en grupos de forma lógica). Util para proyectos grandes.
  - Aislar los componentes que cambian continuamente de los que no.
- Hacer referencia a diferentes recursos entre configuraciones es posible usando *terraform_remote_state*.

```bash
.
├── _modules
│   ├── compute-module
│   │    └── main.tf
│   │    └── variables.tf
│   └── network-module
│        └── main.tf
│        └── variables.tf
├── dev
│   ├── compute
│   │    ├── main.tf
│   │    └── terraform.tfvars
│   ├── network
│   │    ├── main.tf
│   │    └── terraform.tfvars
├── staging
│   ├── compute
│   │    ├── main.tf
│   │    └── terraform.tfvars
│   ├── network
│   │    ├── main.tf
│   │    └── terraform.tfvars
└── prod
    ├── compute
    │    ├── main.tf
    │    └── terraform.tfvars
    ├── network
    │    ├── main.tf
    │    └── terraform.tfvars
```

#### Terragrunt

Terragrunt es una herramienta que nos permite trabajar con múltiples entornos de forma más sencilla.

- Creada por [Gruntwork](https://gruntwork.io/) nos brinda utilidades para hacer ciertos casos de uso de Terraform más sencillos.
  - Enfoque DRY (Don't Repeat Yourself)
  - Ejecuta comando entre múltiples TF configs
  - Facilita trabajar con múltiples cuentas de Cloud

## Testing

### Code Rot

En general, a medida que pasa el tiempo, el código tiende a deteriorarse, muchas partes que conforman nuestro código cambian, las dependencias se actualizan, los servicios cambian, etc. El testing se usa para asegurarse de que esto no impacte de manera negativa en nuestro código, esto es aplicable también con Terraform.

En terraform es común que ocurra que alguien haga un cambio de un recurso mediante la consola, lo cual causa un conflicto con la configuración de terraform. Un test nos puede alertar de esto.

### Tipos de Test para Terraform

#### Static Checks

Los que trae Terraform por defecto, por ejemplo:

- `terraform fmt`
- `terraform validate`
- `terraform plan`
- Reglas de validación personalizadas

```hcl
variable "short_variable" {
  type = string

  validation {
    condition = length(var.short_variable) < 4
    error_message = "The short_variable value must be less than 4 characters!"
  }
}
```

Herramientas externas:

- `tflint`
- `checkov`, `tfsec`, `terrascan`, `terraform-compliance`, `snyk`
- `Terraform Sentinel` (Enterprise only)

### Automated Testing

#### Using Bash

```bash
#!/bin/bash
set -euo pipefail

# Change directory to example
cd ../../examples/hello-world

# Create the resources
terraform init
terraform apply -auto-approve

# Wait while the instance boots up
# (Could also use a provisioner in the TF config to do this)
sleep 60 

# Query the output, extract the IP and make a request
terraform output -json |\
jq -r '.instance_ip_addr.value' |\
xargs -I {} curl http://{}:8080 -m 10

# If request succeeds, destroy the resources
terraform destroy -auto-approve
```

Este script de bash se encarga de desplegar los recursos, esperar a que el servidor este listo, hacer una petición a la IP del servidor y si todo sale bien, destruir los recursos.

#### Using Terratest

Terratest es una librería de Go que nos permite escribir tests para Terraform.

```go
package test

import (
	"crypto/tls"
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformHelloWorldExample(t *testing.T) {
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../../examples/hello-world",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	instanceURL := terraform.Output(t, terraformOptions, "url")
	tlsConfig := tls.Config{}
	maxRetries := 30
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetryWithCustomValidation(
		t, instanceURL, &tlsConfig, maxRetries, timeBetweenRetries, validate,
	)

}

func validate(status int, body string) bool {
	fmt.Println(body)
	return status == 200
}
```

Este test se encarga de desplegar los recursos, esperar a que el servidor este listo, hacer una petición a la IP del servidor y si todo sale bien, destruir los recursos. Lo mismo que el script de bash, pero en Go.

#### Aplicar terraform plan periódicamente

Otra forma de testear nuestro código es aplicar `terraform plan` periódicamente, por ejemplo, en un pipeline de CI/CD, con esto nos aseguramos de que terraform se entere sobre los cambios que se han hecho por fuera de la herramienta.

## Developer Workflows

### General Workflow

- Escribir/actualizar código
- Ejecutar los cambios localmente
- Crear un Pull Request
- Ejecutar los test en un ambiente de Integración Continua
- Hacer el deploy a un ambiente de Staging mediante Continuous Deployment (o hacer merge a la rama principal)
- Hacer el Deploy a Producción mediante Continuous Deployment

### Multi accounts / projects

Algo que se recomienda por el equipo de Terraform es tener una cuenta para cada entorno, para desarrollo, otra para staging y otra para producción.

- Simplifica las IAM policies para reforzar el control para diferentes entornos (y TF backends remotos).

- Aísla los entornos para mitigar el alcance de posibles errores.

- Reduce el conflicto entre recursos con el mismo nombre.

- **Contra**: Añade complejidad a la configuración de Terraform.

### Herramientas adicionales

- `Terragrunt`
  - Minimiza la duplicación del código
  - Permite trabajar con múltiples cuentas de Cloud

- `Cloud Nuke`
  - Fácil limpieza de recursos no deseados

- `Makefiles`
  - Automatiza tareas comunes
  - Previenen errores humanos


### CI/CD

- GitLab CI/CD
- GitHub Actions
- CircleCI
- Atlantis

### Errores comunes

- ``Cambios de nombres cuando se refactoriza el código``, esto hace pensar a Terraform que queremos eliminar un recurso y crear otro con el nuevo nombre.
- ``Datos sensibles en el archivo de estado, por ejemplo, contraseñas, claves privadas, etc.``, esto puede ser target para posibles ataques.
- `Cloud timeouts`, si algún recurso tarda demasiado en crearse, Terraform lo considera como un error, esto puede causar que a veces no se cree la infraestructura correctamente.
- `Conflictos con los nombres de los recursos`, si dos recursos tienen el mismo nombre, Terraform no sabrá a cual de los dos nos referimos.
- `Olvidar destruir test-infra`, podemos llegar a olvidarnos de destruir infraestructura que estábamos usando para pruebas, esto puede causar costos innecesarios.
- `Uni-directional version upgrades`, puede que estemos trabajando con la version 1.0.0 por ejemplo y un compañero ejecuta terraform con la versión 1.1.0, esto causa que nosotros que estábamos trabajando con una versión anterior ya no podamos usar mas terraform hasta que actualicemos nuestra versión.
- `Multiples formas de hacer lo mismo`, esto puede causar confusión y errores.
- `Algunos parámetros son inmutables`, cuando creamos un recurso, algunos parámetros no pueden ser cambiados, por ejemplo, el tamaño de una base de datos, si queremos cambiar el tamaño de la base de datos, debemos destruir la base de datos y crear una nueva.
- `Out of band changes`, si alguien hace un cambio por fuera de Terraform, esto puede causar problemas.

## Workflow con GitHub Actions

```yaml
name: "Terraform"

on:
  # Uncomment to enable staging deploy from main
  # push:
  #   branches:
  #     - main
  release:
    types: [published]
  pull_request:

jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    defaults:
      run:
        working-directory: 07-managing-multiple-environments/file-structure/staging
    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.1
          terraform_wrapper: false

      - name: Terraform Format
        id: fmt
        run: terraform fmt -check

      - name: Terraform Init
        id: init
        run: terraform init

      - name: Terraform Plan
        id: plan
        if: github.event_name == 'pull_request'
        # Route 53 zone must already exist for this to succeed!
        run: terraform plan -var db_pass=${{secrets.DB_PASS }} -no-color
        continue-on-error: true

      - uses: actions/github-script@0.9.0
        if: github.event_name == 'pull_request'
        env:
          PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
            #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
            #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

            <details><summary>Show Plan</summary>

            \`\`\`${process.env.PLAN}\`\`\`

            </details>

            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`;

              
            github.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: output
            })

      - name: Terraform Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1

      - uses: actions/setup-go@v2
        with:
          go-version: '^1.15.5'
          
      - name : Terratest Execution
        if: github.event_name == 'pull_request'
        working-directory: 08-testing/tests/terratest
        run: |
          go test . -v timeout 10m

      - name: Check tag
        id: check-tag
        run: |
          if [[ ${{ github.ref }} =~ ^refs\/tags\/v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo ::set-output name=environment::production
          elif [[ ${{ github.ref }} == 'refs/heads/main' ]]; then echo ::set-output name=environment::staging
          else echo ::set-output name=environment::unknown
          fi

      - name: Terraform Apply Global
        if: github.event_name == 'push' || github.event_name == 'release'
        working-directory: 07-managing-multiple-environments/file-structure/global
        run: |
          terraform init
          terraform apply -auto-approve

      - name: Terraform Apply Staging
        if: steps.check-tag.outputs.environment == 'staging' && github.event_name == 'push'
        run: terraform apply -var db_pass=${{secrets.DB_PASS }} -auto-approve

      - name: Terraform Apply Production
        if: steps.check-tag.outputs.environment == 'production' && github.event_name == 'release'
        working-directory: 07-managing-multiple-environments/file-structure/production
        run: |
          terraform init
          terraform apply -var db_pass=${{secrets.DB_PASS }} -auto-approve
```

Análisis por partes:

```yaml
name: "Terraform"

on:
  # Uncomment to enable staging deploy from main
  # push:
  #   branches:
  #     - main
  release:
    types: [published]
  pull_request:
```

En este bloque se define cuando se va a ejecutar el workflow, en este caso, cuando se haga un release o un pull request.

```yaml
jobs:
  terraform:
    name: "Terraform"
    runs-on: ubuntu-latest
    env:
      AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
      AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    defaults:
      run:
        working-directory: 07-managing-multiple-environments/file-structure/staging
    steps:
      - name: Checkout
        uses: actions/checkout@v2
```

En este bloque se define el job, en este caso, se llama `terraform`, se ejecutará en un ambiente de ubuntu, se definen las variables de entorno y el directorio de trabajo.

```yaml
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: 1.0.1
          terraform_wrapper: false
```

En este bloque se configura Terraform, se define la versión de Terraform que se va a usar.

```yaml
      - name: Terraform Format
        id: fmt
        run: terraform fmt -check

      - name: Terraform Init
        id: init
        run: terraform init
```

En este bloque se ejecutan los comandos `terraform fmt` y `terraform init`.

```yaml
      - name: Terraform Plan
        id: plan
        if: github.event_name == 'pull_request'
        # Route 53 zone must already exist for this to succeed!
        run: terraform plan -var db_pass=${{secrets.DB_PASS }} -no-color
        continue-on-error: true
```

En este bloque se ejecuta el comando `terraform plan`, pero solo si el evento es un pull request.

```yaml
      - uses: actions/github-script@0.9.0
        if: github.event_name == 'pull_request'
        env:
          PLAN: "terraform\n${{ steps.plan.outputs.stdout }}"
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          script: |
            const output = `#### Terraform Format and Style 🖌\`${{ steps.fmt.outcome }}\`
            #### Terraform Initialization ⚙️\`${{ steps.init.outcome }}\`
            #### Terraform Plan 📖\`${{ steps.plan.outcome }}\`

            <details><summary>Show Plan</summary>

            \`\`\`${process.env.PLAN}\`\`\`

            </details>

            *Pusher: @${{ github.actor }}, Action: \`${{ github.event_name }}\`*`
```

En este bloque se crea un comentario en el pull request con los resultados de los comandos anteriores.

```yaml
      - name: Terraform Plan Status
        if: steps.plan.outcome == 'failure'
        run: exit 1
```

En este bloque se verifica si el comando `terraform plan` falló, si es así, se termina el workflow.

```yaml
      - uses: actions/setup-go@v2
        with:
          go-version: '^1.15.5'
          
      - name : Terratest Execution
        if: github.event_name == 'pull_request'
        working-directory: 08-testing/tests/terratest
        run: |
          go test . -v timeout 10m
```

En este bloque se ejecutan los tests de Terratest.

```yaml
      - name: Check tag
        id: check-tag
        run: |
          if [[ ${{ github.ref }} =~ ^refs\/tags\/v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then echo ::set-output name=environment::production
          elif [[ ${{ github.ref }} == 'refs/heads/main' ]]; then echo ::set-output name=environment::staging
          else echo ::set-output name=environment::unknown
          fi
```

En este bloque se verifica si el evento es un release o un push a la rama main.

```yaml
      - name: Terraform Apply Global
        if: github.event_name == 'push' || github.event_name == 'release'
        working-directory: 07-managing-multiple-environments/file-structure/global
        run: |
          terraform init
          terraform apply -auto-approve

      - name: Terraform Apply Staging
        if: steps.check-tag.outputs.environment == 'staging' && github.event_name == 'push'
        run: terraform apply -var db_pass=${{secrets.DB_PASS }} -auto-approve

      - name: Terraform Apply Production
        if: steps.check-tag.outputs.environment == 'production' && github.event_name == 'release'
        working-directory: 07-managing-multiple-environments/file-structure/production
        run: |
          terraform init
          terraform apply -var db_pass=${{secrets.DB_PASS }} -auto-approve
```

En este bloque se ejecutan los comandos `terraform apply` dependiendo del ambiente.