# Guia de estilos NidoApp - HU-02

## Paleta de colores

| Nombre | Hex | Uso |
| --- | --- | --- |
| Primary / Verde Teal | `#2D7D6F` | Acciones principales, estados activos, iconos destacados. |
| Primary Dark / Verde Teal Dark | `#1A574D` | Enfasis, textos sobre fondos suaves, variantes oscuras. |
| Secondary / Azul Suave | `#4A7FD4` | Informacion, enlaces visuales y apoyo a la accion principal. |
| Background / Fondo App | `#F5FFFE` | Fondo general de pantallas. |
| Text / Principal | `#1A2E2C` | Titulos y contenido principal. |
| Text / Secundario | `#4A6B68` | Descripciones, ayudas y detalles secundarios. |
| Semantic / Error | `#D94444` | Errores, validaciones y alertas criticas. |
| Semantic / Exito | `#28A37A` | Confirmaciones y estados exitosos. |
| Surface / Tarjeta | `#FFFFFF` | Tarjetas, inputs y superficies elevadas. |
| Surface / Borde | `#D1E0DE` | Bordes suaves, separadores y contornos. |

## Tipografia

La configuracion queda preparada para usar Inter mediante `fontFamily: Inter`. Si Inter no esta registrado como asset en el proyecto, Flutter usara la fuente disponible por defecto.

| Estilo | Tamano | Peso | Uso |
| --- | --- | --- | --- |
| Titulo principal | 28 | 700 | Encabezados de pantalla y marca. |
| Subtitulo | 20 | 600 | Secciones, tarjetas importantes y bloques de contenido. |
| Texto normal | 16 | 400 | Parrafos y contenido principal. |
| Texto pequeno | 13 | 400 | Metadatos, ayudas y descripciones breves. |
| Texto de boton | 16 | 700 | Botones principales y secundarios. |
| Texto de error o ayuda | 12 | 500 | Validaciones y mensajes de soporte. |

## Componentes creados

- `AppPrimaryButton`: boton principal con color teal, texto blanco, alto de 52, estado de carga y habilitado/deshabilitado.
- `AppSecondaryButton`: boton secundario con borde, fondo blanco y texto en color principal.
- `AppTextField`: campo reutilizable con label, hint, controller, validacion, iconos y estilos globales de input.
- `AppCard`: tarjeta blanca con borde suave, radio, padding y sombra ligera.
- `AppBadge`: etiqueta para tipos de alojamiento como Habitacion, Apartaestudio y Compartido.
- `AppAlert`: alerta reutilizable con variantes info, success y error.
- `AppTheme`: tema global Material 3 con `ColorScheme`, fondo, botones, inputs, tarjetas y textos.

## Intencion visual

El verde teal comunica calma, estabilidad y cercania, valores importantes para una app donde las personas buscan un lugar temporal para vivir. El azul suave complementa la paleta con una sensacion de confianza y claridad. El fondo muy claro reduce ruido visual y las tarjetas blancas ayudan a que alojamientos, perfiles y mensajes sean faciles de escanear.

## Evidencia HU-02

La HU-02 queda cubierta porque el proyecto define una paleta centralizada, estilos tipograficos reutilizables, tema global Material 3 y componentes base para construir pantallas coherentes. Tambien se agrega `StyleGuidePage`, una pantalla de demostracion visual con textos, botones, input, badges, card y alertas.
