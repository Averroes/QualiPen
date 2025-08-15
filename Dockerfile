# =====================================================================
# Pentest Toolbox - Full Kali (monostage)
# =====================================================================
FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive \
    PIPX_HOME=/opt/pipx \
    PIPX_BIN_DIR=/usr/local/bin \
    GOPATH=/root/go \
    WORDLISTS_DIR=/usr/share/seclists \
    VENV_PATH=/opt/venv \
    PATH=/root/go/bin:/opt/pipx/bin:/root/.local/bin:/opt/venv/bin:$PATH \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    LANG=fr_FR.UTF-8 \
    LC_TIME=fr_FR.UTF-8 \
    TERM=xterm-256color
WORKDIR /root

# ------- System packages -------
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates wget curl git git-lfs zsh tmux vim file \
    iputils-ping net-tools dnsutils tcpdump traceroute netcat-traditional iproute2 \
    ruby ruby-dev build-essential default-jre \
    python3 python3-venv python3-pip pipx \
    golang-go libpcap-dev \
    seclists burpsuite zaproxy nmap masscan whatweb dnsrecon theharvester nikto cewl wapiti sqlmap dirsearch \
    fierce sslscan wpscan recon-ng enum4linux-ng samba-common-bin python3-impacket trufflehog findomain \
    command-not-found \
    && dpkg-reconfigure command-not-found \
    && apt-get install -y locales \
    && sed -i 's/# fr_FR.UTF-8 UTF-8/fr_FR.UTF-8 UTF-8/' /etc/locale.gen \
    && locale-gen fr_FR.UTF-8 \
    && update-locale LANG=fr_FR.UTF-8 LC_TIME=fr_FR.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# Fix shebangs éventuels
RUN ln -sf /usr/bin/python3 /usr/local/bin/python

# ------- Virtualenv global pour nos installs pip -------
RUN python3 -m venv $VENV_PATH && \
    $VENV_PATH/bin/pip install --upgrade pip setuptools wheel

# ------- Go tools -------
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest \
 && go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest \
 && go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest \
 && go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest \
 && go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest \
 && go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest \
 && go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest \
 && go install -v github.com/projectdiscovery/katana/cmd/katana@latest \
 && go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest \
 && go install -v github.com/ffuf/ffuf/v2@latest \
 && go install -v github.com/OJ/gobuster/v3@latest \
 && go install -v github.com/d3mondev/puredns/v2@latest \
 && go install -v github.com/owasp-amass/amass/v4/cmd/amass@latest \
 && go install -v github.com/jaeles-project/gospider@latest \
 && go install -v github.com/hakluke/hakrawler@latest \
 && go install -v github.com/sensepost/gowitness@latest \
 && go install -v github.com/lc/gau/v2/cmd/gau@latest \
 && go install -v github.com/jaeles-project/jaeles@latest \
 && go install -v github.com/tomnomnom/assetfinder@latest \
 && go install -v github.com/tomnomnom/httprobe@latest \
 && go install -v github.com/tomnomnom/anew@latest \
 && go install -v github.com/tomnomnom/unfurl@latest \
 && go install -v github.com/tomnomnom/waybackurls@latest \
 && go install -v github.com/tomnomnom/gf@latest \
 && go install -v github.com/BishopFox/jsluice/cmd/jsluice@latest \
 && go install -v github.com/hahwul/dalfox/v2@latest \
 && go install -v github.com/RedTeamPentesting/monsoon@latest

# ------- Python tools via pipx (isolation) -------
RUN pipx install --pip-args='--no-cache-dir' \
      dnstwist sherlock-project arjun h8mail anubis-netsec hashid git-dumper bloodhound-cli

# ------- Repos Python clonés + install -------
WORKDIR /opt/tools
# petite fonction shell pour installer proprement
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -eux; \
    clone() { git clone --depth 1 "$1" "$2"; }; \
    PIP="$VENV_PATH/bin/pip"; PY="$VENV_PATH/bin/python"; \
    clone https://github.com/smicallef/spiderfoot.git spiderfoot && cd spiderfoot && $PIP install -r requirements.txt && cd ..; \
    clone https://github.com/infosec-au/altdns.git altdns && cd altdns && $PIP install -r requirements.txt && $PY setup.py install && cd ..; \
    clone https://github.com/devanshbatham/ParamSpider.git ParamSpider && cd ParamSpider && $PIP install . && cd ..; \
    clone https://github.com/GerbenJavado/LinkFinder.git LinkFinder && cd LinkFinder && $PIP install -r requirements.txt && cd ..; \
    clone https://github.com/s0md3v/uro.git uro && cd uro && $PIP install . && cd ..; \
    clone https://github.com/yassineaboukir/asnlookup.git asnlookup && cd asnlookup && $PIP install -r requirements.txt && cd ..; \
    clone https://github.com/vortexau/dnsvalidator.git dnsvalidator && cd dnsvalidator && $PY setup.py install && cd ..; \
    clone https://github.com/sa7mon/S3Scanner.git S3Scanner; \
    $PIP install requests xmltodict; \
    clone https://github.com/defparam/smuggler.git smuggler; \
    clone https://github.com/lobuhi/byp4xx.git byp4xx; \
    clone https://github.com/swisskyrepo/SSRFmap.git SSRFmap && cd SSRFmap && $PIP install -r requirements.txt && cd ..; \
    clone https://github.com/EnableSecurity/wafw00f.git wafw00f && cd wafw00f && $PY setup.py install && cd ..; \
    clone https://github.com/s0md3v/XSStrike.git XSStrike && cd XSStrike && $PIP install -r requirements.txt && cd ..

# ------- Ruby tools -------
RUN gem install evil-winrm --no-document

# ------- Post-exploitation scripts -------
WORKDIR /opt/scripts
RUN curl -L -o linpeas.sh https://github.com/peass-ng/PEASS-ng/releases/download/20250701-bdcab634/linpeas_fat.sh && \
    curl -L -o winPEASany.exe https://github.com/peass-ng/PEASS-ng/releases/download/20250701-bdcab634/winPEASany.exe || true && \
    git clone --depth 1 https://github.com/rebootuser/LinEnum.git /opt/LinEnum && \
    cp /opt/LinEnum/LinEnum.sh /opt/scripts/ && \
    chmod +x /opt/scripts/linpeas.sh /opt/scripts/LinEnum.sh || true

# ------- Symlinks wordlists utiles -------
WORKDIR /root
RUN ln -s $WORDLISTS_DIR/Discovery/DNS/subdomains-top1million-110000.txt /root/subdomains.txt && \
    ln -s $WORDLISTS_DIR/Discovery/Web-Content/directory-list-2.3-medium.txt /root/dirs.txt

# ------- Oh-My-Zsh -------
RUN set -eux; \
    clone() { git clone --depth 1 "$1" "$2"; }; \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended && \
    clone https://github.com/rupa/z.git ~/.oh-my-zsh/custom/plugins/z  && \
    clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting && \
    clone https://github.com/zsh-users/zsh-history-substring-search ~/.oh-my-zsh/custom/plugins/history-substring-search

COPY ./base_config/.zshrc /root/.zshrc

WORKDIR /root/data
CMD ["zsh"]