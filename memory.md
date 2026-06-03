# MEMORY — Sistema Textos Escolares 2026
> Archivo para guardar todo lo importante que Mónica pide recordar sobre la app.

---

## Infraestructura

| Componente | Detalle |
|---|---|
| **URL en vivo** | https://strong-centaur-9a6a74.netlify.app |
| **GitHub** | https://github.com/sistemasmonica/sistema-textos |
| **Supabase** | https://pqluiqsvfeddmxpuxyhm.supabase.co |
| **Branch** | `main` |
| **Archivo principal** | `index.html` |

---

## Tablas en Supabase (creadas 2026-06-03)

| Tabla | Qué guarda |
|---|---|
| `txe_registros` | Facturas XML, compras manuales, ventas |
| `txe_banco` | Movimientos bancarios |
| `txe_conciliaciones` | Conciliaciones bancarias |
| `txe_movinventario` | Entradas y salidas de inventario |
| `txe_guias` | Guías de retiro |
| `txe_colegios` | Lista de colegios |
| `txe_coldata` | Datos detallados por colegio |
| `txe_config` | Configuración (clave Claude API, etc.) |
| `app_data` | Tabla antigua — se mantiene como respaldo |

---

## Notas importantes

- El sistema guarda en **localStorage** (rápido) Y en **Supabase** (nube) al mismo tiempo
- El indicador **☁️ Guardado** en el encabezado confirma que la nube está conectada
- Los **1,996 productos** del Kardex están embebidos en el HTML — nunca se guardan en la nube
- La **clave Claude API** se guarda en `txe_config` con key `claude_key`

---

## Historial de decisiones importantes

| Fecha | Decisión |
|---|---|
| 2026-06-03 | Migración de 1 tabla (`app_data` clave única) a 8 tablas separadas para evitar borrado cruzado |
| 2026-06-03 | Archivo renombrado de `SISTEMA_TEXTOS_2026.html` a `index.html` para compatibilidad Netlify |
| 2026-06-03 | CSS responsive agregado para uso en celulares |

---

## Recordatorios de Mónica

### Modelo de negocio (explicado por Mónica, 2026-06-03)
- Compra libros a **editoriales** a crédito a **6 meses plazo**
- Vende a **escuelas y colegios** en temporada de inicio de clases
- Los libros no vendidos se **devuelven a la editorial** → editorial emite **notas de crédito**
- Paga a la editorial al final: facturas - notas de crédito = lo que realmente debe
- Da **comisiones** a colegios y librerías por las ventas que le permiten hacer
- Las comisiones se llaman "**capacitación**" y vienen como facturas **sin IVA**
