# Configurar Terraform

Primero debemos [descargar](https://developer.hashicorp.com/terraform/install) Terraform desde su pagina oficial, en ella se muestra como descargarlo para diferentes sistemas operativos.

Luego, debemos configurar las credenciales del proveedor cloud de nuestra elección, en este caso AWS. Para esto debemos ingresar a la consola de AWS y buscar el servicio `IAM`, con este servicio vamos a crear un nuevo usuario y le vamos a otorgar permisos para acceder a los servicios de AWS, podemos escoger a que servicios puede acceder. Este usuario creado será el que usará Terraform para interactuar con AWS. Mediante el CLI de AWS configuramos las credenciales del usuario creado en nuestro sistema.

```bash
aws configure
```

Este comando nos pedirá primero el `AWS Access Key ID` el cual debemos crear en la consola de AWS en el servicio `IAM` en el usuario que creamos, accedemos a la pestaña `Security credentials` y luego con el botón `Create access key` creamos el `Access Key ID` y el `Secret Access Key` que también nos solicitará el comando `aws configure`. También nos pedirá el `Default region name` y el `Default output format`, estos los podemos dejar en blanco o configurarlos según nuestra preferencia. Esto nos creará un archivo en nuestro sistema `~/.aws/credentials` con las credenciales que acabamos de configurar.

Con esto ya tenemos Terraform configurado para interactuar con AWS.