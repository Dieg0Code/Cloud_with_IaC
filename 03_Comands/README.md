# Comandos de Terraform

Una vez ya configuradas las credenciales para poder interactuar con el Cloud Provider de nuestra elección, podemos empezar a utilizar Terraform para crear nuestra infraestructura.

Para inicializar un proyecto de Terraform:

```bash
terraform init
```

Esto inicializa Terraform en el directorio actual.

Ejemplo simple de un archivo de configuración de Terraform:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

Este es un ejemplo simple de un archivo de configuración de Terraform que crea una instancia EC2 en AWS.

Para planificar los cambios que se van a realizar en la infraestructura:

```bash
terraform plan
```

Este comando nos muestra todas las acciones que va a realizar Terraform para crear la infraestructura que definimos en el archivo de configuración.

Para aplicar los cambios y crear la infraestructura:

```bash
terraform apply
```

Con este comando aplicamos el plan que nos mostró anteriormente Terraform con el comando `terraform plan`. Nos mostrará un resumen de los cambios que va a realizar y nos pedirá confirmación para aplicarlos.

Para destruir la infraestructura creada:

```bash
terraform destroy
```

Con este comando destruimos toda la infraestructura que creamos con Terraform. Nos pedirá confirmación antes de realizar la acción.

Este sería la secuencia de comandos básicos para usar Terraform