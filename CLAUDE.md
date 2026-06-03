# Sistema Textos Escolares 2026 — Contexto del Proyecto

## Quién es el usuario
- Negocio: Distribuidor de textos escolares en Quito, Ecuador
- GitHub: `sistemasmonica` / Email: `asesor.didactica5@gmail.com`
- Supabase org: `sistemasmonica` / proyecto: `sistemalibros`

## Qué es la aplicación
Sistema completo de control de negocio en un solo archivo HTML (`index.html`).

**Módulos:**
- Dashboard con métricas (ventas, compras, utilidad, inventario)
- XML+IA — importa facturas XML del SRI Ecuador con clasificación via Claude API
- Manual — ingreso manual de gastos/compras
- Ventas — registro de ventas a colegios
- Colegios — control por institución (kits, financiero, control de entregas)
- Banco — conciliación bancaria (importa CSV/Excel del banco)
- Inventario — 1,996 productos pre-cargados (Kardex editoriales Ecuador), entradas, guías de retiro
- Movimientos — historial completo con filtros
- Declaraciones SRI — Formulario 104 (IVA) y 102 (Renta), Anexo compras
- Reportes — exportación CSV/Excel

## Infraestructura actual
| Componente | Detalle |
|---|---|
| Código fuente | https://github.com/sistemasmonica/sistema-textos |
| Base de datos | Supabase — https://pqluiqsvfeddmxpuxyhm.supabase.co |
| Deploy | Netlify (conectar manualmente — ver pendientes abajo) |
| Branch principal | `main` |

## Credenciales
- **Supabase anon key**: guardada directamente en `index.html` (constante `SUPA_KEY`)
- **GitHub token**: generar nuevo en GitHub → Settings → Developer settings → Personal access tokens (el anterior puede haber sido revocado por push protection)

## Arquitectura de datos (Supabase)
Tabla: `app_data`
```sql
CREATE TABLE IF NOT EXISTS app_data (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
ALTER TABLE app_data DISABLE ROW LEVEL SECURITY;
GRANT ALL ON app_data TO anon;
GRANT ALL ON app_data TO authenticated;
```
- Clave `txe_v4` → toda la data del negocio (regs, banco, movInv, guias, colegios, colData)
- Clave `claude_key` → API key de Anthropic del usuario

## Cómo funciona la sincronización
1. Al cargar la página: lee `localStorage` (rápido) + llama `syncFromCloud()` async
2. `syncFromCloud()` trae datos de Supabase, actualiza `localStorage`, re-renderiza
3. Cada `save()` escribe en `localStorage` Y en Supabase (`saveToCloud()` async)
4. Indicador en el header: `☁️ Guardado` / `🔄 Sincronizando...` / `⚠️ Sin conexión`

## PENDIENTES (tareas para próxima sesión)
- [x] **HECHO**: Tabla `app_data` creada en Supabase (confirmado 2026-06-03)
- [x] **HECHO**: Netlify conectado a GitHub, deploy automático funcionando (2026-06-03)
- [x] **HECHO**: Archivo renombrado a `index.html` (2026-06-03)
- [x] **HECHO**: CSS responsive para celulares agregado (2026-06-03)
- [x] **HECHO**: Migración a tablas separadas en Supabase — ☁️ Guardado confirmado (2026-06-03)
  - Tablas: txe_registros, txe_banco, txe_conciliaciones, txe_movinventario, txe_guias, txe_colegios, txe_coldata, txe_config
- [ ] (Opcional) Personalizar el nombre del sitio Netlify en Site settings

## Archivos del proyecto
```
sistema_textos/
├── index.html     ← app completa (único archivo)
├── netlify.toml   ← config de Netlify
├── CLAUDE.md      ← instrucciones para Claude
└── memory.md      ← notas importantes y recordatorios de Mónica
```

## Cómo hacer deploy de cambios
```bash
# Editar index.html
git add index.html
git commit -m "descripcion del cambio"
git push origin main
# Netlify auto-despliega en ~30 segundos
```

## Dependencias CDN (no requieren instalación)
- Tabler Icons: `https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/`
- xlsx.js: `https://cdn.jsdelivr.net/npm/xlsx@0.18.5/`
- Supabase JS v2: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/`

---

## COMANDOS DE SESIÓN — INSTRUCCIONES PARA CLAUDE

> Estos comandos los escribe Mónica al inicio y fin de cada sesión de trabajo.
> Claude DEBE ejecutarlos automáticamente sin pedir confirmación adicional.

### Cuando Mónica escribe "iniciar sesion" (o variantes: "iniciar sesión", "inicio"):
Ejecutar EN ORDEN los siguientes pasos y reportar el resultado de cada uno:

1. `git pull origin main` — traer últimos cambios del servidor
2. `git status` — mostrar qué archivos han cambiado
3. `git log --oneline -5` — mostrar los últimos 5 cambios guardados
4. Leer el archivo `CLAUDE.md` y mostrar la lista de PENDIENTES actuales
5. Mostrar un resumen claro: **"Todo listo para trabajar. Últimos cambios: [X]. Pendientes: [Y]."**

### Cuando Mónica escribe "cerrar" (o variantes: "cerrar sesion", "cerrar sesión", "guardar y cerrar"):
Ejecutar EN ORDEN los siguientes pasos y reportar el resultado de cada uno:

1. `git status` — ver qué archivos cambiaron en esta sesión
2. `git add index.html CLAUDE.md netlify.toml` — preparar archivos (solo los que existan y hayan cambiado)
3. `git add -A` — incluir cualquier archivo nuevo que se haya creado
4. `git commit -m "Actualización [fecha de hoy]: [resumen breve de los cambios hechos en la sesión]"` — guardar con descripción automática
5. `git push origin main` — subir al servidor GitHub
6. Confirmar con mensaje: **"Todo guardado y subido. Netlify desplegará la versión nueva en ~30 segundos."**
7. Si el push falla por falta de token, explicar a Mónica el error en términos simples y dar el paso a seguir.

### Notas importantes para Claude:
- Mónica NO sabe programación — usar lenguaje simple, sin jerga técnica
- Si algo falla, explicar QUÉ pasó y QUÉ tiene que hacer Mónica (un paso concreto)
- El branch siempre es `main`, el repo es `sistemasmonica/sistema-textos`
- Netlify se despliega automáticamente cuando el push a `main` es exitoso
- Si hay conflictos de merge, resolverlos favoreciendo los cambios locales (los de Mónica)
