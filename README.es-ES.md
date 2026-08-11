

# Configuración de Neovim

Esta es mi configuración de Neovim de uso diario. Utiliza [LazyVim](https://github.com/LazyVim/LazyVim) como base, mantiene la instalación de plugins explícita y excluye las herramientas de IA dependientes de red de la ruta de inicio normal.

![Panel de Neovim](https://github.com/user-attachments/assets/1a8fe839-d31b-4478-bb60-9793903254ca)

## Qué incluye

- Configuración de LSP usando `vim.lsp`
- Autocompletado con Blink.cmp
- Integración con Git mediante Gitsigns, Lazygit y Diffview
- Ejecución de pruebas y tareas con Neotest y Overseer
- Historial de deshacer persistente con Undotree
- Navegación con Telescope, Grapple y Oil
- Integraciones opcionales de Copilot, Sidekick, Avante y MCPHub
- Línea de estado, línea de búferes, diagnósticos y renderizado de Markdown personalizados

## Requisitos

- Neovim 0.13 o superior
- Git
- Rust, usado para compilar Blink.cmp desde su rama `main`
- Una Nerd Font si deseas usar los iconos configurados
- Los servidores de lenguaje, formateadores, linters y depuradores necesarios para tus proyectos

Ripgrep y Lazygit son opcionales, pero varios flujos de trabajo de búsqueda y Git requieren que estén disponibles.

## Instalación

Haz una copia de seguridad de cualquier configuración existente y luego clona este repositorio:

```sh
mv ~/.config/nvim ~/.config/nvim.bak
git clone https://github.com/abzcoding/nv.git ~/.config/nvim
nvim
```

El primer lanzamiento inicializa `lazy.nvim` en el commit registrado en `lazy-lock.json`.
No instala automáticamente el resto de los plugins faltantes. Revisa el archivo de bloqueo y luego restaura sus versiones exactas desde dentro de Neovim:

```vim
:Lazy restore
```

Reinicia Neovim una vez que finalice la restauración.

## Actualización de plugins y confianza

`lazy-lock.json` forma parte de esta configuración y debe mantenerse bajo control de versiones.
Las verificaciones automáticas de actualización, las especificaciones de plugins locales, las Lua rocks y la instalación al inicio están desactivadas.
Esto previene cambios no deseados en las dependencias; no hace que los plugins de terceros sean seguros. Los plugins y sus ganchos de construcción aún se ejecutan con los permisos de tu usuario.

Al actualizar los plugins:

1. Ejecuta `:Lazy update` deliberadamente.
2. Revisa los cambios en el código fuente y el diff de `lazy-lock.json`.
3. Prueba la configuración antes de confirmar el nuevo archivo de bloqueo.

Para volver a las versiones confirmadas, restaura `lazy-lock.json` desde el control de versiones y luego ejecuta `:Lazy restore`.

Esta configuración no es un entorno aislado para repositorios maliciosos. Para una sesión de edición rápida y sin plugins, usa:

```sh
nvim --clean --noplugin -i NONE path/to/file
```

Usa un entorno aislado o contenedor a nivel del sistema operativo cuando el repositorio mismo requiera un aislamiento más estricto.

## Herramientas de IA

Los plugins de IA se cargan de forma diferida en lugar de iniciarse con Neovim. Presiona `<leader>aE` (`Espacio a E`) para cargar el conjunto configurado y habilitar:

- Elementos de autocompletado de Copilot en Blink.cmp
- Sugerencias de próxima edición de Sidekick
- Avante
- MCPHub, cuando existe `~/.mcpservers.json`

Los comandos individuales de los plugins aún pueden cargar sus respectivos plugins sin habilitar todo el conjunto. La autenticación de proveedores y las claves API se gestionan fuera de este repositorio.

Establece `NVIM_OFFLINE=1` para desactivar las integraciones de IA dependientes de red para una sesión:

```sh
NVIM_OFFLINE=1 nvim
```

Para mantenerlas desactivadas por defecto, agrega esto a tu perfil de shell:

```sh
export NVIM_OFFLINE=1
```

Mientras el modo sin conexión esté activo, `<leader>aE` mostrará una advertencia y no hará nada. Desconfigura la variable antes de iniciar Neovim para habilitar la IA nuevamente.

MCPHub solo se habilita cuando existe `~/.mcpservers.json`. Su entorno de ejecución externo debe instalarse por separado; esta configuración no ejecuta una instalación global de npm por ti.

El servicio RAG de Avante está desactivado por defecto. Sus integraciones opcionales de RAG y búsqueda web requieren servicios locales adicionales o credenciales; consulta `lua/plugins/avante.lua` antes de habilitarlas.

## Comandos y asignaciones útiles

| Comando o asignación | Acción                                           |
| ------------------ | ------------------------------------------------ |
| `<leader>aE`       | Habilitar el conjunto de IA                      |
| `<leader>aM`       | Abrir MCPHub cuando esté configurado             |
| `<leader>uT`       | Alternar Undotree                                |
| `<leader>cf`       | Formatear documento                              |
| `<leader>cs`       | Esquema del documento                            |
| `<leader>sr`       | Buscar y reemplazar                              |
| `<leader>gdd`      | Abrir Diffview                                   |
| `<leader>gdm`      | Diferenciar contra la rama main del remoto       |
| `<leader>gD`       | Mostrar el historial del archivo actual          |
| `<leader>oo`       | Seleccionar y ejecutar tarea de Overseer         |
| `<leader>ol`       | Reiniciar la última tarea de Overseer            |
| `<leader>ud`       | Desactivar diagnósticos                          |
| `:Lint`            | Ejecutar el linter configurado para el búfer actual |
| `:LintTerraform`   | Ejecutar manualmente la validación de Terraform y TFLint |
| `:LintTrivy`       | Ejecutar Trivy manualmente                       |

LazyVim proporciona la mayoría de las asignaciones restantes. Presiona `<leader>` y sigue las etiquetas de WhichKey para descubrirlas.

## Estructura de la configuración

- `lua/config/options.lua` — opciones del editor y detección de tipo de archivo
- `lua/config/keymaps.lua` — asignaciones globales
- `lua/config/autocmds.lua` — autocomandos
- `lua/config/utils.lua` — funciones de utilidad compartidas
- `lua/plugins/*.lua` — especificaciones y configuración de plugins

## Capturas de pantalla

![Avante en Neovim](https://github.com/user-attachments/assets/f1f93baa-892f-48dd-810d-460a205231f8)

![Neotest y Overseer](https://github.com/user-attachments/assets/0ecde105-2744-4705-800a-35345db47fc9)
