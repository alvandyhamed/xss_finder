# 🛡️ XSS Recon Automation Script

This project provides a fully automated Bash script for discovering potential XSS vectors in web applications. It performs:

- Subdomain discovery
- URL collection from web archives
- Parameterized URL extraction and cleanup
- POST parameter discovery
- Optional XSS vulnerability testing via Dalfox

---

## ⚙️ Requirements
Ensure the following tools are installed **globally** before running the script:

```bash
sudo apt install golang -y  # or brew install go on macOS
go install github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/lc/gau@latest
go install github.com/tomnomnom/waybackurls@latest
pip install git+https://github.com/devanshbatham/paramspider.git
GO111MODULE=on go install github.com/hahwul/dalfox/v2@latest
```

Ensure `$GOPATH/bin` and your Python `venv/bin` are in your `$PATH`:

```bash
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
source ~/.bashrc
```

---

## 🚀 How to Use

### 1. Clone the repository:
```bash
git clone https://your-git-repo/xss-recon
cd xss-recon
```

### 2. Make the script executable:
```bash
chmod +x xss_recon_final.sh
```

### 3. Run the script:
```bash
./xss_recon_final.sh
```

You will be prompted to enter a domain name, and then asked if you want to run Dalfox. If yes, you’ll be guided through:

1. Lite vs Hard scan
2. Dalfox execution mode
3. Attack type (Reflected, Blind, DOM, etc.)

---

## 📁 Output Files
All results will be saved under:
```bash
~/xss-recon/<your-domain>/
```

This includes:
- `subdomains.txt`
- `live-subdomains.txt`
- `all-urls.txt`
- `urls-with-params-clean.txt`
- `post-links.txt`
- `xss-scan-report.txt` (if Dalfox was used)
- `dalfox-report.html` (optional)

---

## 👥 Notes for Team Use
- Every team member must run the script from the same base folder.
- Tools must be installed per user.
- A single alias can be added for easier usage:

```bash
echo 'alias xss-recon="bash ~/xss-recon/xss_recon_final.sh"' >> ~/.bashrc
source ~/.bashrc
```

Then you can simply run:
```bash
xss-recon
```

