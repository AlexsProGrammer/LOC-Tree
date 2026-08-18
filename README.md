# LOC-Tree (Line-Of-Code Tree Analyzer)

A lightweight multi-platform utility to recursively inspect codebases, filter out small files, and render a clean, pruned tree hierarchy showing only files that exceed a specified line-count threshold.

Ideal for auditing large monolithic scripts that need refactoring or splitting into smaller modules.

---

## Features

- **Tree Visualization**: Generates a clean tree view with proper directory branches (`├──`, `└──`).
- **Branch Pruning**: Automatically hides empty directories and branches containing zero qualifying files.
- **Relative Path Display**: Paths are displayed cleanly relative to your target scan directory.
- **Zero Heavy Dependencies**: Implemented in native Python standard libraries, pure Bash, PowerShell, and legacy Windows Batch.

---

## Available Implementations

| Script | Runtime / Platform | Best For |
| :--- | :--- | :--- |
| `codetree.py` | Python 3.6+ (Cross-Platform) | Full feature set, precise parsing, optional flag control |
| `codetree.sh` | Bash 4.0+ (macOS / Linux / WSL) | Unix environments without external Python installations |
| `codetree.ps1` | PowerShell 5.1+ / PS Core (Windows / Cross-Platform) | Native Windows administrative scripting and automation |
| `codetree.bat` | Command Prompt (`cmd.exe` on Windows) | Legacy systems and quick double-click execution |

---

## Quick Start & Usage

### 1. Python (`codetree.py`)

#### Requirements
- Python 3.6 or higher (uses standard library modules: `argparse`, `pathlib`, `sys`).

#### Syntax
```bash
python3 codetree.py [FOLDER] [-l MIN_LINES] [--all]

```

#### Examples

```bash
# Scan current directory with default 200-line threshold
python3 codetree.py

# Scan a specific directory for files with more than 500 lines
python3 codetree.py ./src -l 500

# Include hidden files/folders (e.g., dotfiles like .config)
python3 codetree.py /path/to/project -l 100 --all

```

---

### 2. Bash (`codetree.sh`)

#### Requirements

* Bash environment (`Linux`, `macOS`, or `Git Bash` / `WSL` on Windows).

#### Setup

```bash
chmod +x codetree.sh

```

#### Syntax

```bash
./codetree.sh [TARGET_DIR] [MIN_LINES]

```

#### Examples

```bash
# Scan current folder with default 200-line threshold
./codetree.sh

# Scan target directory for files longer than 350 lines
./codetree.sh ./scripts 350

# Scan parent directory for files longer than 1,000 lines
./codetree.sh .. 1000

```

---

### 3. PowerShell (`codetree.ps1`)

#### Requirements

* Windows PowerShell 5.1+ or PowerShell Core (`pwsh`).

#### Syntax

```powershell
.\codetree.ps1 [[-Path] <String>] [[-MinLines] <Int32>] [-IncludeHidden]

```

#### Examples

```powershell
# Scan current directory with default 200-line threshold
.\codetree.ps1

# Specify folder and custom line threshold
.\codetree.ps1 -Path "C:\Projects\Monorepo" -MinLines 400

# Include hidden files
.\codetree.ps1 .\src 150 -IncludeHidden

```

---

### 4. Windows Batch (`codetree.bat`)

#### Requirements

* Windows Command Prompt (`cmd.exe`).

#### Syntax

```cmd
codetree.bat [TARGET_DIR] [MIN_LINES]

```

#### Examples

```cmd
:: Run in current directory with default 200-line threshold
codetree.bat

:: Scan a subfolder for files with more than 300 lines
codetree.bat "C:\MyScripts" 300

:: Run from within the folder directly with 100-line threshold
codetree.bat . 100

```

---

## Sample Output

```text
Scanning './src' for files with > 250 lines...

📁 src/
├── 📁 controllers/
│   ├── 📁 auth/
│   │   └── 📄 session_handler.py (342 lines)
│   └── 📄 api_gateway.py (618 lines)
├── 📁 services/
│   └── 📄 billing_service.py (410 lines)
└── 📄 server.py (289 lines)

```

---

## License

MIT License. Free to use, modify, and distribute for personal or commercial projects.
