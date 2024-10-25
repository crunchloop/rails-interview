# Rails TodoList API

Esta es una aplicación API en Rails que permite gestionar listas de tareas (todo lists) y sus elementos de tareas (todo items).

La idea de la implementacion es poder usar Active Jobs con Sidekiq para manejar eficientemente el uso de tareas de alto coste y que no afecten la performance de la app.

## Requisitos previos

Asegúrate de tener instalados los siguientes programas antes de continuar:

- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) - Asegúrate de tener la versión especificada en `Gemfile`
- [Bundler](https://bundler.io/) - Instalador de dependencias para Ruby
- [Rails](https://rubyonrails.org/) - Framework de la aplicación
- [PostgreSQL](https://www.postgresql.org/download/) - Sistema de base de datos

## Configuración del Proyecto

1. **Clona el repositorio**:

    ```bash
    git clone https://github.com/r1goo/rails-interview
    cd rails-interview
    ```

2. **Instala las dependencias**:

    Asegúrate de instalar las gemas necesarias usando Bundler:

    ```bash
    bundle install
    ```

3. **Configura la Base de Datos**:

    Crea y migra la base de datos de la aplicación:

    ```bash
    rails db:create
    rails db:migrate
    ```

4. **Carga los datos de prueba**:

    Si deseas cargar datos de prueba, puedes usar el comando `db:seed`:

    ```bash
    rails db:seed
    ```
  Genera un TodoList con 1000 TodoItems.

## Ejecución de la Aplicación

1. **Inicia el servidor de Rails, Redis y Sidekiq**:

    Ejecuta los siguientes comandos para iniciar el servidor y sus utilidades:

    ```bash
    rails server
    redis-server
    bundle exec sidekiq
    ```

    La aplicación estará disponible en `http://localhost:3000`.
    La interfaz grafica de Sidekiq en  `http://localhost:3000/sidekiq/`

2. **Swagger**:

    Existe un documento de swagger que se puede visualizar en: `http://localhost:3000/api-docs`.

3. **Postman**:

    Existe un archivo de postman en la raiz de la solucion con ejemplos de los metodos del controlador de TodoList

## Pruebas:

Esta aplicación utiliza `RSpec` para pruebas. Para ejecutar las pruebas, utiliza el siguiente comando:

```bash
bundle exec rspec
```

Para ver la covertura ejecutar en la consola:

open coverage/index.html 

coverage. 78 / 122 LOC (63.93%) covered.

## Comentarios finales:

- Se considero el uso de JBuilder para la construcción de las respuestas Json de forma mantenible y escalable
- Se corrigieron los endpoint de forma tal que TodoItem tenga una dependencia de vida con TodoList.
- Manejo de errores basicos.
- Tests con Rspec
- Active jobs para el manejo de tareas en segundo plano junto con sidekiq.
- Para el refresco se utilizo Hotwire con Turbo.
- Hecho con amor por r1go@live.com
