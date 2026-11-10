# Diccionario Brunca

Diccionario español–brunca (boruca) bidireccional, ligero y sin conexión, hecho en Flutter. Proyecto del TCU TC-736 *Remembranza* de la Universidad de Costa Rica.

## Contenido

- [Qué hay en este repositorio](#qué-hay-en-este-repositorio)
- [Inicio rápido](#inicio-rápido)
- [Preparar el entorno](#preparar-el-entorno)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Modelo de datos y base de datos](#modelo-de-datos-y-base-de-datos)
- [Tareas comunes](#tareas-comunes)
- [Pruebas y diagnóstico](#pruebas-y-diagnóstico)
- [Transcripción del diccionario](#transcripción-del-diccionario)
- [Wireframe](#wireframe)

## Qué hay en este repositorio

```
diccionario_brunca/
├── diccionario/app/   App móvil (Flutter)
├── wireframe/         Prototipo interactivo de la interfaz (React + Vite)
└── README.md          Este archivo
```

Casi todo el trabajo ocurre en `diccionario/app/`. Los comandos de este README se ejecutan desde esa carpeta, salvo que se indique otra.

## Inicio rápido

Con el entorno ya preparado (siguiente sección) y un emulador abierto o un teléfono conectado:

```bash
git clone <URL-de-este-repositorio>
cd diccionario_brunca/diccionario/app
flutter pub get
flutter run
```

- `flutter devices` lista los destinos disponibles; `flutter run -d <id>` elige uno.
- La primera compilación para Android tarda varios minutos (Gradle descarga dependencias). Las siguientes son mucho más rápidas.
- La plataforma de referencia es el emulador de Android. El código tiene además una rama para escritorio (Linux, Windows, macOS) con `sqflite_common_ffi`. La web no está soportada.

## Preparar el entorno

Versiones con las que se desarrolló (salida de `flutter doctor -v`):

| Herramienta | Versión |
|---|---|
| Flutter | 3.47.1 (stable) |
| Dart | 3.13.1 (el proyecto exige `^3.6.2`) |
| Android SDK | 36 (plataforma android-37.0, build-tools 36.0.0) |
| JDK | 21 |
| Python | 3.8 o superior (solo para `tools/`) |
| Node / npm | 22 / 10 (solo para `wireframe/`) |
| Sistema | Fedora Linux 42 |

Los comandos están escritos para Linux y macOS. En Windows usa `py` o `python` en lugar de `python3`.

1. Instala Flutter siguiendo la [guía oficial](https://docs.flutter.dev/get-started/install).
2. Instala Android Studio. En **SDK Manager** instala el Android SDK, las Build-Tools, las Command-line Tools y el Emulator.
3. Acepta las licencias: `flutter doctor --android-licenses`.
4. En **Device Manager** crea un dispositivo virtual tipo Pixel con una imagen de sistema reciente.
5. Corre `flutter doctor -v`. Las secciones *Flutter* y *Android toolchain* deben salir sin errores.

Si Gradle falla por la versión de Java, apunta Flutter a un JDK 21:

```bash
flutter config --jdk-dir="/ruta/al/jdk-21"
```

## Estructura del proyecto

```
diccionario/app/
├── lib/
│   ├── main.dart                      Punto de entrada: MaterialApp → HomeShell
│   ├── models/word.dart               Word, WordExample, WordPhrase
│   ├── database/database_helper.dart  SQLite: esquema, migración, carga del vocabulario, búsqueda, favoritos
│   ├── utils/text_fold.dart           foldForSearch(): normaliza texto para buscar
│   ├── screens/
│   │   ├── home_shell.dart            Barra inferior (Buscar / Favoritos)
│   │   ├── search_screen.dart         Búsqueda y lista de resultados
│   │   ├── favorites_screen.dart      Lista de favoritos
│   │   └── word_detail_screen.dart    Detalle de una entrada
│   └── widgets/entry_tile.dart        Fila de resultado (la usan búsqueda y favoritos)
├── assets/data/
│   ├── words.json                     Vocabulario que carga la app (GENERADO: no editar a mano)
│   └── words.version                  Hash del contenido (GENERADO)
├── tools/
│   ├── build_words.py                 Valida words_src.json y genera los dos archivos de arriba
│   └── words_src.json                 Fuente editable del vocabulario
├── test/text_fold_test.dart           Pruebas de foldForSearch
├── android/                           Configuración de Android y Gradle
└── pubspec.yaml                       Dependencias y assets
```

### Dónde está cada cosa

| Funcionalidad | Archivo | Qué buscar |
|---|---|---|
| Búsqueda y orden de resultados | `database/database_helper.dart` | `searchWords`, `_searchSql` |
| Normalización de texto (tonos, ᵛ, n̈) | `utils/text_fold.dart` | `foldForSearch` |
| Favoritos | `database/database_helper.dart` | `toggleFavorite`, `getFavorites` |
| Carga del vocabulario desde el JSON | `database/database_helper.dart` | `_syncSeed`, `_seedRow` |
| Esquema y migraciones | `database/database_helper.dart` | `_schemaVersion`, `_createSchema`, `_onUpgrade` |
| Barra inferior; tocar "Buscar" reinicia la búsqueda | `screens/home_shell.dart` | `_onTabTapped`, `reset()` en `SearchScreenState` |
| Detalle de la entrada | `screens/word_detail_screen.dart` | `_buildHeader`, `_buildSenses`, `_buildPhrase` |
| Botón de audio | `screens/word_detail_screen.dart` | Es un marcador: muestra un aviso y no reproduce nada |

### Dependencias

| Paquete | Para qué |
|---|---|
| `sqflite` | Base de datos SQLite en Android e iOS |
| `sqflite_common_ffi` | SQLite en escritorio |
| `path_provider` | Ruta de la base de datos en escritorio |
| `just_audio` | Declarado para el audio; todavía no se usa en `lib/` |

## Modelo de datos y base de datos

Cada entrada del diccionario (clase `Word`) tiene:

| Campo | Contenido |
|---|---|
| `id` | Identificador estable (por ejemplo `abi-h1`). Los favoritos dependen de él |
| `brunca`, `variants` | Palabra en brunca y sus variantes (`abí`, `abíj`) |
| `homograph` | Número cuando el libro numera palabras iguales (`1 abí`, `2 abí`) |
| `pos`, `posLabel` | Categoría gramatical abreviada (`sust.`) y completa (`sustantivo`) |
| `senses` | Significados en español, uno por elemento |
| `literal`, `note` | Traducción literal y nota |
| `examples`, `phrases` | Ejemplos y locuciones, con su traducción |
| `category`, `audioFile` | Opcionales; el audio aún no se usa |

La base de datos se llama `dicionario_brunca.db` (sin la "c": es el nombre real, no lo "corrijas" sin escribir una migración) y tiene tres tablas:

- `entries`: el vocabulario. Se reemplaza completa cuando cambia `words.version`.
- `favorites`: lo que marca la persona usuaria (`entry_id`, `added_at`). Nunca se toca al recargar el vocabulario.
- `meta`: guarda la versión del vocabulario ya cargado (`seed_version`).

**Cómo llega el vocabulario a la base de datos.** Al abrir la base de datos, la app compara `assets/data/words.version` con `seed_version`. Si son distintos, borra `entries`, carga `words.json` en una sola transacción y guarda la versión nueva. Por eso cambiar palabras **no** requiere subir la versión del esquema.

**Versión del esquema.** `_schemaVersion` solo se sube cuando cambia la *estructura* de las tablas (ver [Tareas comunes](#tareas-comunes)).

**Búsqueda.** Cada entrada guarda copias "plegadas" de su texto (`s_head`, `s_gloss`, `s_other`): minúsculas, sin tonos, `ᵛ` como `v`, `n̈` y `ñ` como `n`. La consulta de la persona pasa por la misma función, así que escribir `abuv` encuentra `abuᵛ` y `ajt` encuentra `ajt` y `ájt`. Los resultados se ordenan por relevancia: primero coincidencia exacta con la palabra brunca, luego exacta con un significado, después las que empiezan con el texto, y al final las que lo contienen o lo mencionan en ejemplos, locuciones, categoría gramatical o notas. Se devuelven como máximo 50.

## Tareas comunes

- **Agregar o corregir palabras:** ver [Transcripción del diccionario](#transcripción-del-diccionario).
- **Cambiar la estructura de la base de datos** (por ejemplo, una columna nueva):
  1. Sube `_schemaVersion` en `database_helper.dart`.
  2. Agrega un bloque `if (oldVersion < N)` en `_onUpgrade`.
  3. Actualiza `_createSchema` para las instalaciones nuevas.
  4. Actualiza `Word.fromMap` (`models/word.dart`) y, si el dato viene del JSON, `_seedRow`.
  5. Si es un campo nuevo del vocabulario, agrégalo también a `ALLOWED_KEYS` y a la compilación en `tools/build_words.py`.
- **Cambiar el orden de los resultados de búsqueda:** el `CASE` de `match_rank` en `_searchSql`.
- **Agregar una pantalla:** crea el archivo en `lib/screens/` y navega con `Navigator.push`, como hace `_openDetail` en `search_screen.dart`. Las pestañas de la barra inferior están en `home_shell.dart`.
- **Permitir una letra o abreviatura nueva en el vocabulario:** `EXTRA_ALLOWED` y `POS_LABELS` en `tools/build_words.py`.
- **Agregar una dependencia:** `flutter pub add <paquete>` y haz commit de `pubspec.yaml` y `pubspec.lock`.

## Pruebas y diagnóstico

```bash
flutter analyze
flutter test
python3 tools/build_words.py --check
```

- `flutter test` corre 9 pruebas y todas deben pasar.
- `flutter analyze` hoy reporta 2 avisos informativos en `database_helper.dart` (un import de `sqflite` innecesario y `path` sin declarar en `pubspec.yaml`). No bloquean nada. Cualquier otro aviso es nuevo y conviene revisarlo.
- `build_words.py --check` valida el vocabulario sin escribir archivos.

### Problemas frecuentes

| Síntoma | Causa probable | Qué hacer |
|---|---|---|
| Cambié el vocabulario y la app muestra el anterior | No se regeneró `words.version`, o la app no se reinició | Corre `build_words.py`, detén la app y ejecuta `flutter run` otra vez (un hot reload no vuelve a abrir la base de datos) |
| `Unable to load asset: assets/data/...` | Falta un archivo o la carpeta no está declarada | Verifica que existan `assets/data/words.json` y `words.version`, que `pubspec.yaml` tenga `- assets/data/` bajo `assets:`, y corre `flutter pub get` |
| Quiero probar con una base de datos nueva | La base de datos persiste en el dispositivo entre ejecuciones | Desinstala la app del emulador, o ejecuta `adb shell pm clear <applicationId>` (el `applicationId` está en `android/app/build.gradle`) |
| `flutter doctor` marca licencias pendientes | Licencias de Android sin aceptar | `flutter doctor --android-licenses` |
| Errores extraños tras cambiar dependencias o versiones | Caché de compilación | `flutter clean && flutter pub get` |
| `build_words.py` dice `unexpected character U+XXXX` | Carácter pegado desde un PDF u otra fuente | Ver [Transcripción del diccionario](#transcripción-del-diccionario) |

### Gradle y emulador

- Las versiones de Gradle y del plugin de Android están en `android/gradle/wrapper/gradle-wrapper.properties` y `android/settings.gradle`.
- Si el build de Gradle falla: `flutter clean && flutter pub get`, revisa `flutter doctor -v` y confirma que Flutter usa JDK 21.
- Si el emulador se comporta raro o no arranca: en Device Manager usa *Cold Boot Now*, o *Wipe Data* si persiste.

## Transcripción del diccionario

Flujo completo:

```
PDF del diccionario → tools/words_src.json → build_words.py → assets/data/words.json + words.version → app
```

Solo se edita `tools/words_src.json`. Los dos archivos de `assets/data/` los genera el script y **no se tocan a mano**.

### Cómo escribir el brunca

La ortografía tiene dos signos que no están en un teclado normal. Para no copiarlos, el script los genera a partir de atajos. Estos atajos aplican **solo a los campos en brunca** (`brunca`, `variants`, y el texto en brunca de `examples` y `phrases`). El español se escribe normal.

| En el diccionario | Escribe | Resultado |
|---|---|---|
| Tono alto: á é í ó ú | `á é í ó ú` | igual |
| ᵛ (v elevada: oclusiva glotal) | `v` | `ᵛ` |
| n con diéresis (nasal velar) | `n:` | `n̈` |
| ñ (nasal palatal) | `ñ` | igual |

La `v` no es una letra del brunca: toda `v` en un campo en brunca se convierte en `ᵛ`. Los tonos distinguen palabras (`ajt` y `ájt` son entradas distintas), así que nunca los quites ni unifiques.

### Formato de una entrada

Una entrada de `words_src.json`:

```json
{
  "id": "aiv",
  "brunca": "áiv",
  "pos": "v.",
  "senses": ["matar", "cazar"],
  "phrases": [
    { "brunca": "yáv áiv", "spanish": "combatir", "literal": "matarse" }
  ]
}
```

| Campo | Obligatorio | Notas |
|---|---|---|
| `id` | sí | Único y **nunca cambia** una vez publicado. Minúsculas, sin tildes, solo `a-z`, `0-9` y guiones. Se escribe la `v` como `v` |
| `brunca` | sí | Palabra tal como está en el libro, con los atajos de arriba |
| `senses` | sí | Lista de significados en español, uno por elemento. Si el libro numera las acepciones, una por número |
| `variants` | no | Formas alternativas (`abí, abíj`) |
| `homograph` | no | Número, si el libro numera palabras iguales. En el `id` se agrega `-h1`, `-h2`: `abi-h1`, `abi-h2` |
| `pos` | no | Abreviatura del libro (`sust.`, `v.`, `adj.`...). Solo se aceptan las de `POS_LABELS` en `build_words.py` |
| `literal` | no | Traducción literal de la entrada ("literalmente: ...") |
| `examples` | no | Lista de `{ "brunca", "spanish" }` |
| `phrases` | no | Lista de `{ "brunca", "spanish", "literal" }` (`literal` es opcional) |
| `note` | no | Notas del libro |
| `source_page` | no | Página del libro; solo para rastrear, no llega a la app |
| `needs_review` | no | `true` si tienes dudas; solo para el equipo, no llega a la app |
| `review_note` | no | Qué duda tienes |

Si te falta el `id`, el script te sugiere uno.

### Paso a paso

1. Abre `tools/words_src.json` y agrega las entradas en el mismo orden del libro.
2. Valida y genera los archivos, desde `diccionario/app/`:
   ```bash
   python3 tools/build_words.py
   ```
3. Si hay errores, el script los lista, indica el `id` y el campo, y **no escribe nada**. Corrígelos y vuelve a correrlo. Un error de carácter incluye el código Unicode del símbolo problemático.
4. Si todo está bien, el script imprime cuántas entradas generó y la lista de las que siguen marcadas con `needs_review`.
5. Detén la app y ejecuta `flutter run`. Busca las palabras nuevas, con y sin tonos.
6. Haz commit de **los tres archivos juntos**: `words_src.json`, `words.json` y `words.version`.

Antes de entregar una versión: `python3 tools/build_words.py --strict` falla mientras quede alguna entrada con `needs_review`.

### Qué valida el script

- Que existan `id`, `brunca` y `senses`, y que no haya campos mal escritos.
- Que los `id` no se repitan y tengan formato válido.
- Que dos entradas no compartan la misma palabra sin números de homógrafo distintos.
- Que la abreviatura de `pos` exista en la lista.
- Que los campos en brunca solo tengan letras de la ortografía. Esto atrapa letras de otros alfabetos que *se ven* iguales, signos de más pegados desde un PDF y `v` sueltas.
- Que todo el texto quede normalizado (NFC).

Si copias texto desde el PDF, revisa siempre lo pegado: puede traer caracteres que se ven bien pero no son los correctos. El script los detecta, pero es más rápido escribir las palabras que pegarlas.

### Puntos por confirmar

Estas dudas siguen abiertas. Marca con `needs_review` las entradas afectadas:

- La abreviatura `art.` aparece en las entradas pero no en la leyenda de abreviaturas que se revisó. Por ahora se interpreta como "artículo" (provisional).
- Cuando el libro separa con comas varias glosas, no siempre es claro si son acepciones distintas o partes de una sola definición (por ejemplo `abí drubát`). Ante la duda, marca `needs_review`.

## Wireframe

`wireframe/` es un prototipo interactivo de la interfaz hecho con React y Vite. Se usó para diseñar las pantallas y se presentó en la primera gira a Rey Curré. No está conectado con la app y puede estar desactualizado respecto a ella.

```bash
cd wireframe
npm install
npm run dev
```

Vite muestra en la terminal la dirección local para abrirlo en el navegador (Vite usa normalmente `http://localhost:5173`).
