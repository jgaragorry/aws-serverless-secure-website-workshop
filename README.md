# Workshop: Zero-Cost Secure Static Website on AWS | A DevSecOps & FinOps Masterclass

![Arquitectura del Workshop](https://user-images.githubusercontent.com/8525625/228800532-6a75f28a-8c46-4a41-8f2c-5b914a51e6b3.png) 
*<p align="center">Diagrama de la arquitectura final que desplegaremos.</p>*

---

## 1. Introducción al Workshop

### 1.1. Propósito y Objetivo

Bienvenido a este workshop práctico diseñado para llevar tus habilidades en la nube al siguiente nivel. El objetivo es desplegar una aplicación web estática en AWS de manera **segura, automatizada y con un enfoque proactivo en el control de costos (FinOps)**.

A través de este ejercicio, no solo construirás una solución funcional, sino que también comprenderás y aplicarás las mejores prácticas de **DevOps, DevSecOps, SRE y Cloud Engineering**, creando un proyecto tangible y de alto valor para tu portafolio profesional.

### 1.2. ¿A quién está dirigido?

Este workshop está diseñado para un **nivel intermedio**. Se espera que tengas conocimientos fundamentales sobre:

* Conceptos básicos de la nube (¿qué es una VM, almacenamiento de objetos, CDN?).
* Uso básico de la línea de comandos y Git.
* Nociones de qué es la Infraestructura como Código (IaC).

**Nunca asumiremos conocimiento avanzado**. Cada paso, concepto y decisión técnica será explicado en detalle.

### 1.3. Tecnologías y Disciplinas que Cubriremos

| Disciplina | Herramienta/Concepto | Propósito en el Workshop |
| :--- | :--- | :--- |
| **Cloud Engineering** | AWS (S3, CloudFront, ACM, Route 53) | Construir la infraestructura serverless para alojar nuestro sitio web de forma escalable y eficiente. |
| **Infraestructura como Código (IaC)** | Terraform | Definir, versionar y gestionar toda nuestra infraestructura de AWS de manera declarativa y reproducible. |
| **DevOps / CI/CD** | GitHub Actions | Automatizar el proceso de validación, planificación y despliegue de nuestra infraestructura y código. |
| **DevSecOps** | AWS WAF, OAC, Security Headers | Integrar la seguridad desde el diseño, protegiendo nuestro sitio contra ataques comunes y asegurando las comunicaciones. |
| **FinOps** | AWS Budgets, Tagging, Automatización | Implementar control de costos proactivo, monitorear gastos y asegurar la limpieza de recursos para evitar facturas inesperadas. |

---

## 2. Arquitectura de la Solución

La solución que implementaremos es 100% serverless, lo que significa que no gestionaremos servidores, y solo pagaremos por el uso real (que, para un sitio con tráfico bajo-medio, estará dentro de la capa gratuita de AWS).

El flujo es el siguiente:

1.  **Desarrollador:** Realiza un cambio en el código del sitio web (en la carpeta `/src`) o en la infraestructura (en la carpeta `/terraform`) y lo sube a GitHub.
2.  **GitHub Actions (CI/CD):** Un `push` a la rama `main` activa nuestro workflow automatizado.
3.  **Validación y Planificación:** El workflow primero valida el código de Terraform, lo formatea y genera un plan de ejecución.
4.  **Despliegue con Terraform:** GitHub Actions ejecuta `terraform apply`, que se comunica con AWS para crear o actualizar los siguientes recursos:
    * **Route 53:** Gestiona el dominio DNS para nuestro sitio.
    * **AWS Certificate Manager (ACM):** Provee un certificado SSL/TLS gratuito para habilitar HTTPS.
    * **S3 Bucket:** Almacena los archivos estáticos (HTML, CSS, JS) de nuestro sitio web.
    * **CloudFront Distribution (CDN):** Actúa como nuestra red de entrega de contenido. Acelera la entrega del sitio a nivel global, proporciona el cifrado HTTPS y se comunica de forma segura con S3.
    * **Origin Access Control (OAC):** Una política que asegura que el bucket S3 solo pueda ser accedido a través de CloudFront.
    * **AWS WAF:** Un firewall de aplicaciones web que protege nuestro sitio de vulnerabilidades comunes.
    * **CloudFront Function:** Una pequeña función que inyecta cabeceras de seguridad en la respuesta HTTP para robustecer la seguridad del cliente.
5.  **Sincronización de Contenido:** Una vez la infraestructura está desplegada, un paso en el mismo workflow sube el contenido de la carpeta `/src` al bucket S3.
6.  **FinOps - Control de Costos:**
    * **AWS Budgets:** Un presupuesto configurado vía Terraform que nos alertará si los costos superan un umbral definido (ej. $1).
    * **Workflow de Destrucción:** Un segundo workflow manual (`destroy.yml`) nos permitirá destruir toda la infraestructura con un solo clic, asegurando un costo de $0 al finalizar el laboratorio.
7.  **Usuario Final:** Accede al sitio web a través de un dominio personalizado, con una conexión rápida y segura (HTTPS).

---

## 3. Prerrequisitos

Antes de comenzar, asegúrate de tener todo lo siguiente.

| Componente | Instrucciones y Propósito |
| :--- | :--- |
| **Cuenta de AWS** | Necesitarás una cuenta activa de AWS. Si no tienes una, puedes crearla [aquí](https://aws.amazon.com/free/). **Propósito:** Es la plataforma en la nube donde desplegaremos toda nuestra infraestructura. |
| **Dominio Registrado** | Necesitarás un nombre de dominio (ej. `mi-workshop-increible.com`). Puedes registrarlo en Amazon Route 53, GoDaddy, Namecheap, etc. **Propósito:** Para acceder a nuestro sitio con un nombre amigable y poder generar un certificado SSL. |
| **Cuenta de GitHub** | Si estás leyendo esto, es probable que ya la tengas. **Propósito:** Alojar nuestro código y ejecutar los pipelines de CI/CD con GitHub Actions. |
| **Terraform CLI** | Instala la CLI de Terraform en tu máquina local. Sigue la [guía oficial](https://learn.hashicorp.com/tutorials/terraform/install-cli). **Propósito:** Aunque la automatización se ejecuta en GitHub Actions, tener la CLI localmente es esencial para pruebas y desarrollo. |
| **AWS CLI** | Instala la CLI de AWS en tu máquina local. Sigue la [guía oficial](https://aws.amazon.com/cli/). **Propósito:** Para configurar tus credenciales y poder interactuar con tu cuenta de AWS desde la terminal. |

---

## 4. Estructura del Repositorio

Para mantener el orden y seguir las mejores prácticas, nuestro repositorio se organiza de la siguiente manera:
