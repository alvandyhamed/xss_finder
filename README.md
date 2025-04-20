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

When you launch the script, a custom ASCII banner will appear like this:

```
  ___ ___                           .__________              .__        
 /   |   \_____    _____   ____   __| _/\   _  \ ___  ___    |__|______ 
/    ~    \__  \  /     \_/ __ \ / __ | /  /_\  \  \/  /    |  \_  __ \
\    Y    // __ \|  Y Y  \  ___// /_/ | \  \_/   \>    <     |  ||  | \/
 \___|_  /(____  /__|_|  /\___  >____ |  \_____  /__/_\_ \ /\ |__||__|   
       \/      \/      \/     \/     \/        \/      \/ \/            
```
This replaces the default Dalfox splash and gives you visual feedback that the script is running.

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

## 🎯 Attack Types – Explained

| Mode | Name                         | Description |
|------|------------------------------|-------------|
| 1    | **Reflected XSS**            | Tests for classic XSS where user input is reflected directly into the response without sanitization. |
| 2    | **Stored XSS**               | Attempts to inject payloads that persist (e.g., in a comment or profile field) and get executed later. |
| 3    | **DOM-Based XSS**            | Focuses on JavaScript sinks in the DOM that may execute user-controlled data (e.g. `document.location`). |
| 4    | **Blind XSS**                | Injects payloads designed to trigger in places the attacker cannot immediately see (like admin panels). Requires a listener. |
| 5    | **Parameter Analysis**       | Identifies parameters that show reflective or behavioral anomalies that could lead to XSS. |
| 6    | **BAV (Bad Access Vector)**  | Tries to break out of contexts using payloads that can disrupt tag/attribute structures. |
| 7    | **Encoder Bypass**           | Uses encoded versions of payloads (e.g., `&#x3C;`, `%3C`, etc.) to bypass WAFs or poorly written filters. |
| 8    | **Polyglot Payloads**        | Sends universal payloads that can work across multiple contexts (attribute, script, tag). |
| 9    | **Context-Aware Injection**  | Dalfox automatically chooses the best payload based on where the input is injected (tag body, attr, JS, etc.). |
| 10   | **Reflection Grepping**      | Highlights exact locations where your input is reflected back in the response for manual follow-up. |
| 11   | **Header Injection Testing** | Tries injecting payloads into headers like `User-Agent`, `Referer`, etc. to check for downstream reflection. |
| 12   | **Static File Testing**      | Targets `.js`, `.json`, `.xml` files that might expose sensitive or injectable values. |
| 13   | **MIME Sniffing XSS**        | Checks misconfigured `Content-Type` headers that let browsers interpret responses incorrectly (e.g., treat HTML as JS). |


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

