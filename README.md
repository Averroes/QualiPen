# QualiPen Setup

Clone and run this on a Linux (recommended: Ubuntu 22.04 LTS) to configure both the machine and your individual pentest environment as follows:

```sh
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/Averroes/QualiPen.git
cd QualiPen
python3 install_qualipen.py
```

See also [QualiPen Documentation](https://github.com/Averroes/QualiPen) for more details and usage instructions.

## Quick Start

- Build the Docker image:
  ```sh
  qualipen build path/to/../Dockerfile
  ```
- Launch an interactive shell:
  ```sh
  qualipen shell nom_container
  ```
- Launch Burp Suite Pro (after downloading Burp in `burp_installer`):
  ```sh
  qualipen burp nom_container
  ```
- Launch OWASP ZAP:
  ```sh
  qualipen zap nom_container
  ```

## Directory Structure

```
.qualipen
├── base_config          # Fichier de config de base
│   └── burp_installer   # Fichier pour installer burp
│       └── README.md
├── bin
│   └── qualipen         # Executable qui gère le wrapper python
├── common               # Dossier partagé à tous les containers
├── config.yml           # Fichier de configuration
├── data                 # Dossier contenant les containers
│   └── exemple
└── my_config            # Fichier de configuration personel
```

---

For further customization or advanced usage, see the [README.md](README.md) and script comments.
