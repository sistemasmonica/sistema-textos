# Sistema Textos Escolares 2026 — Contexto del Proyecto

## Quién es el usuario
- Negocio: Distribuidor de textos escolares en Quito, Ecuador
- GitHub: `sistemasmonica` / Email: `asesor.didactica5@gmail.com`
- Supabase org: `sistemasmonica` / proyecto: `sistemalibros`

## Qué es la aplicación
Sistema completo de control de negocio en un solo archivo HTML (`SISTEMA_TEXTOS_2026.html`).

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
- **Supabase anon key**: guardada directamente en `SISTEMA_TEXTOS_2026.html` (constante `SUPA_KEY`)
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
- [ ] **CRÍTICO**: Crear tabla en Supabase — correr el SQL de arriba en el SQL Editor del dashboard
- [ ] **CRÍTICO**: Conectar repo GitHub a Netlify para deploy automático
  - netlify.com → Add site → Import from GitHub → sistemasmonica/sistema-textos → branch main → publish dir `.`
- [ ] Verificar que la sincronización cloud funciona abriendo la URL de Netlify
- [ ] (Opcional) Personalizar el nombre del sitio Netlify en Site settings

## Archivos del proyecto
```
sistema_textos/
├── SISTEMA_TEXTOS_2026.html   ← app completa (único archivo)
├── netlify.toml               ← config de Netlify
└── CLAUDE.md                  ← este archivo
```

## Cómo hacer deploy de cambios
```bash
# Editar SISTEMA_TEXTOS_2026.html
git add SISTEMA_TEXTOS_2026.html
git commit -m "descripcion del cambio"
git push origin main
# Netlify auto-despliega en ~30 segundos
```

## Dependencias CDN (no requieren instalación)
- Tabler Icons: `https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@2.44.0/`
- xlsx.js: `https://cdn.jsdelivr.net/npm/xlsx@0.18.5/`
- Supabase JS v2: `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/`
