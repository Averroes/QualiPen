#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import os
import shutil
import sys
import subprocess
from pathlib import Path
import textwrap

HOME = Path.home()
TARGET_ROOT = HOME / ".qualipen"
BIN_DIR = TARGET_ROOT / "bin"
REPO_ROOT = Path(__file__).resolve().parent  # racine du repo

TARGETS = {
    "config_file": ("config.yml",  TARGET_ROOT / "config.yml"),
    "base_config": ("base_config", TARGET_ROOT / "base_config"),
    "my_config":   ("my_config",   TARGET_ROOT / "my_config"),  # mkdir seulement
    "data":        ("data",        TARGET_ROOT / "data"),       # mkdir seulement
    "common":      ("common",      TARGET_ROOT / "common"),     # mkdir seulement
    "cli":         ("qualipen",    BIN_DIR / "qualipen"),
}

BLOCK_BEGIN = "# >>> qualipen >>>"
BLOCK_END   = "# <<< qualipen <<<"

def info(msg): print(f"• {msg}")
def ok(msg):   print(f"✅ {msg}")
def warn(msg): print(f"⚠️  {msg}")
def err(msg):  print(f"❌ {msg}", file=sys.stderr)

def ensure_pyyaml():
    try:
        import yaml  # noqa: F401
        return
    except Exception:
        info("PyYAML manquant — installation en cours (user site)...")
        rc = subprocess.call([sys.executable, "-m", "pip", "install", "--user", "pyyaml"])
        if rc != 0:
            warn("Impossible d’installer PyYAML automatiquement. Installe-le manuellement : pip install --user pyyaml")

def copy_file(src: Path, dst: Path, force: bool, dry: bool):
    if not src.exists():
        raise FileNotFoundError(f"Fichier introuvable: {src}")
    dst.parent.mkdir(parents=True, exist_ok=True)
    if dst.exists() and not force:
        info(f"Conservé (existe déjà) : {dst}")
        return
    info(f"Copie fichier -> {dst}")
    if not dry:
        shutil.copy2(src, dst)

def copy_dir(src: Path, dst: Path, merge: bool, force: bool, dry: bool):
    if not src.exists():
        raise FileNotFoundError(f"Dossier introuvable: {src}")
    if dst.exists():
        if force:
            info(f"Suppression du dossier existant : {dst}")
            if not dry:
                shutil.rmtree(dst)
        elif merge:
            info(f"Fusion des contenus vers : {dst}")
            if not dry:
                for root, dirs, files in os.walk(src):
                    rel = Path(root).relative_to(src)
                    (dst / rel).mkdir(parents=True, exist_ok=True)
                    for f in files:
                        s = Path(root) / f
                        d = (dst / rel) / f
                        if d.exists():
                            continue
                        shutil.copy2(s, d)
            return
        else:
            info(f"Dossier déjà présent (utilise --merge ou --force pour remplacer) : {dst}")
            return
    info(f"Copie dossier -> {dst}")
    if not dry:
        shutil.copytree(src, dst)

def make_executable(path: Path):
    if os.name != "nt":
        try:
            mode = path.stat().st_mode
            path.chmod(mode | 0o111)
        except Exception as e:
            warn(f"Impossible de rendre exécutable {path}: {e}")

def ensure_windows_wrapper():
    if os.name != "nt":
        return
    wrapper = BIN_DIR / "qualipen.cmd"
    content = textwrap.dedent(r"""\
        @echo off
        set "QP_BIN=%USERPROFILE%\.qualipen\bin"
        if exist "%QP_BIN%\qualipen" (
            where py >NUL 2>&1
            if %ERRORLEVEL%==0 (
                py -3 "%QP_BIN%\qualipen" %*
            ) else (
                python "%QP_BIN%\qualipen" %*
            )
        ) else (
            echo qualipen introuvable dans %%USERPROFILE%%\.qualipen\bin
            exit /b 1
        )
    """)
    if not wrapper.exists():
        wrapper.write_text(content, encoding="utf-8")

def add_to_path(no_path: bool):
    if no_path:
        return

    bin_str = str(BIN_DIR)

    # Windows
    if os.name == "nt":
        current = os.environ.get("PATH", "")
        if bin_str.lower() in current.lower():
            info(r"~\.qualipen\bin déjà dans PATH (session courante).")
            return
        info("Ajout de ~/.qualipen/bin au PATH utilisateur (Windows)")
        rc = subprocess.call(
            ["setx", "PATH", current + (";" if current and not current.endswith(";") else "") + bin_str],
            shell=True
        )
        if rc == 0:
            ok("PATH mis à jour (ouvre un nouveau terminal PowerShell/cmd).")
        else:
            warn("Échec setx PATH. Ajoute manuellement %USERPROFILE%\\.qualipen\\bin au PATH utilisateur.")
        return

    # Unix-like → cible en fonction du shell
    shell = (os.environ.get("SHELL") or "").lower()
    target = None
    shell_name = None

    if "zsh" in shell:
        target = HOME / ".zshrc"
        shell_name = "zsh"
    elif "bash" in shell:
        target = HOME / ".bashrc"
        shell_name = "bash"
    elif "fish" in shell:
        confd = HOME / ".config" / "fish" / "conf.d"
        confd.mkdir(parents=True, exist_ok=True)
        conf = confd / "qualipen.fish"
        line = f'set -gx PATH "{bin_str}" $PATH'
        if conf.exists() and line in conf.read_text(encoding="utf-8", errors="ignore"):
            info("PATH déjà configuré pour fish (conf.d/qualipen.fish).")
            return
        conf.write_text("# QualiPen PATH\n" + line + "\n", encoding="utf-8")
        ok(f'PATH ajouté pour fish dans {conf}. Recharge:  exec fish  (ou ouvre un nouveau terminal)')
        return
    else:
        target = HOME / ".profile"
        shell_name = "profile"

    line = 'export PATH="$HOME/.qualipen/bin:$PATH"'
    block = f"{BLOCK_BEGIN}\n{line}\n{BLOCK_END}\n"

    if target.exists():
        txt = target.read_text(encoding="utf-8", errors="ignore")
        if BLOCK_BEGIN in txt:
            info(f"Bloc PATH QualiPen déjà présent dans {target}.")
            return

    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("a", encoding="utf-8") as f:
        f.write("\n" + block)

    ok(f'PATH ajouté pour {shell_name} dans {target}. Recharge:  source "{target}"  (ou ouvre un nouveau terminal)')

def main():
    parser = argparse.ArgumentParser(description="Installe ~/.qualipen en copiant depuis ce repo (Linux/macOS/Windows)")
    parser.add_argument("--merge", action="store_true",
                        help="Fusionner les dossiers existants (base_config uniquement)")
    parser.add_argument("--force", action="store_true",
                        help="Mettre à jour le CLI 'qualipen' et 'base_config' (remplacement)")
    parser.add_argument("--yaml", action="store_true",
                        help="Remplacer uniquement ~/.qualipen/config.yml")
    parser.add_argument("--no-path", action="store_true",
                        help="Ne pas modifier le PATH")
    parser.add_argument("--dry-run", action="store_true",
                        help="Afficher sans écrire")
    args = parser.parse_args()

    print(f"Repo source   : {REPO_ROOT}")
    print(f"Cible install : {TARGET_ROOT}\n")

    # Prépare .qualipen/bin
    if not args.dry_run:
        BIN_DIR.mkdir(parents=True, exist_ok=True)

    # 1) config.yml
    src_cfg = REPO_ROOT / TARGETS["config_file"][0]
    # --yaml => force la mise à jour du YAML ; sinon on conserve s'il existe
    copy_file(src_cfg, TARGETS["config_file"][1], force=args.yaml, dry=args.dry_run)

    # 2) base_config
    src_base = REPO_ROOT / TARGETS["base_config"][0]
    dst_base = TARGETS["base_config"][1]
    if src_base.exists():
        copy_dir(src_base, dst_base, merge=args.merge, force=args.force, dry=args.dry_run)
    else:
        info("base_config/ absent dans le repo — création d'un dossier vide côté cible.")
        if not args.dry_run:
            dst_base.mkdir(parents=True, exist_ok=True)

    # 3) my_config, data, common : mkdir seulement
    for key in ("my_config", "data", "common"):
        dst = TARGETS[key][1]
        info(f"Création du dossier (si absent) : {dst}")
        if not args.dry_run:
            dst.mkdir(parents=True, exist_ok=True)

    # 4) CLI qualipen
    src_cli = REPO_ROOT / TARGETS["cli"][0]
    # --force => met à jour le CLI, sinon conserve si déjà présent
    copy_file(src_cli, TARGETS["cli"][1], force=args.force, dry=args.dry_run)
    if not args.dry_run:
        make_executable(TARGETS["cli"][1])
        ensure_windows_wrapper()

    # 5) PATH & PyYAML
    if not args.dry_run:
        add_to_path(args.no_path)
        ensure_pyyaml()

    ok("Installation terminée.")
    print("\nEssaye :")
    if os.name == "nt":
        print(r'  Ouvre un nouveau terminal, puis:  qualipen --help')
    else:
        shell = (os.environ.get("SHELL") or "").lower()
        if "zsh" in shell:
            print('  source ~/.zshrc   # (ou rouvre ton terminal)')
        elif "fish" in shell:
            print('  exec fish         # (ou rouvre ton terminal)')
        else:
            print('  source ~/.bashrc  # (ou rouvre ton terminal)')
        print('  qualipen --help')

if __name__ == "__main__":
    main()
