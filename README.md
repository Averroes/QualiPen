# QualiPen Setup

Clone and run this on a Linux (recommended: Ubuntu 22.04 LTS) to configure both the machine and your individual pentest environment as follows:

```sh
cd $HOME
sudo apt-get update
sudo apt-get install -y git
git clone https://github.com/Averroes/QualiPen.git
cd QualiPen
./build.sh
```

See also [QualiPen Documentation](https://github.com/Averroes/QualiPen) for more details and usage instructions.

## Quick Start

- Build the Docker image:
  ```sh
  ./build.sh
  ```
- Launch an interactive shell:
  ```sh
  ./run-shell.sh
  ```
- Launch Burp Suite Pro (after downloading Burp in `burp_installer`):
  ```sh
  ./run-burp.sh
  ```
- Launch OWASP ZAP:
  ```sh
  ./run-zap.sh
  ```

## Directory Structure

- `data/` — Stores results from your tools.
- `burp_installer/` — Place Burp Suite installation scripts/files here.

---

For further customization or advanced usage, see the [README.md](README.md) and script comments.
