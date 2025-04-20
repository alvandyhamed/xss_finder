#!/bin/bash

RED="\033[0;31m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
NC="\033[0m"

REQUIRED_TOOLS=("assetfinder" "httpx" "gau" "waybackurls" "paramspider")

for tool in "${REQUIRED_TOOLS[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}❌ ابزار $tool نصب نیست. لطفاً نصبش کن و دوباره اجرا کن.${NC}"
        exit 1
    fi
done

read -p "🔍 لطفاً دامنه را وارد کن (مثال: example.com): " domain

start_time=$(date +%s)
echo -e "${BLUE}🚀 شروع عملیات برای ${domain}...${NC}"

mkdir -p ~/xss-recon/$domain
cd ~/xss-recon/$domain || exit

echo -ne "${BLUE}[1/9] Running assetfinder...${NC}
"
# جمع‌آوری ساب‌دامین‌ها و حذف تکراری‌ها با و بدون پروتکل
assetfinder --subs-only $domain | sed 's/^https:\/\///' | sed 's/^http:\/\///' | sed 's/^www\.//' | sort -u > subdomains.txt

echo -ne "${BLUE}[2/9] Probing with httpx...${NC}
"
# بررسی دامنه‌های زنده
cat subdomains.txt | httpx -silent | sed 's/^https:\/\///' | sed 's/^http:\/\///' | sed 's/^www\.//' | sort -u > live-subdomains.txt

echo -ne "${BLUE}[3/9] Fetching URLs with gau and waybackurls...${NC}
"
# استخراج URLها
cat live-subdomains.txt | while read line; do echo https://$line; done | tee formatted.txt | gau > gau.txt
cat formatted.txt | waybackurls > wayback.txt
cat gau.txt wayback.txt | sort -u > all-urls.txt

echo -ne "${BLUE}[4/9] Filtering parameterized URLs...${NC}
"
# فیلتر لینک‌های دارای پارامتر
cat all-urls.txt | grep "=" > urls-with-params.txt

echo -ne "${BLUE}[5/9] Removing static/API entries...${NC}
"
# حذف فایل‌های استاتیک و APIهای خاص
cat urls-with-params.txt | grep -vE "\.(js|css|png|jpg|jpeg|svg|woff|woff2|ttf|eot|ico|gif|map|json|xml|webp|pdf)(\?|$)" | grep -v "/wp-json/" > urls-with-params-clean.txt

echo -ne "${BLUE}[6/9] Normalizing and deduplicating URLs...${NC}
"
# نرمال‌سازی و حذف پورت 80 و تکراری‌ها
cat urls-with-params-clean.txt | sed 's/:80//' | sed 's/^https:\/\///' | sed 's/^http:\/\///' | sed 's/^www\.//' | sort -u > tmp.txt && mv tmp.txt urls-with-params-clean.txt

echo -ne "${BLUE}[7/9] Running ParamSpider for POST discovery...${NC}
"
# اجرای ParamSpider برای POST URLs
paramspider -d $domain > post-links.txt

echo -ne "${BLUE}[8/9] Preparing Dalfox options...${NC}
"
# اجرای Dalfox
read -p "❓ Do you want to run Dalfox for XSS testing? [y/n]: " confirm
if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    echo -e "${YELLOW}📘 Select test level:
  1) Lite - Fast and minimal
  2) Hard - Full mining and DOM"
    read -p "Your choice [1/2]: " level

    echo -e "${YELLOW}📘 Select Dalfox mode:
  1) dalfox url
  2) dalfox file
  3) dalfox pipe
  4) dalfox server
  5) dalfox scan
  6) dalfox --blind"
    read -p "Your choice [1-6]: " mode

    echo -e "${YELLOW}📘 Select attack type:
  1) Reflected XSS
  2) Stored XSS
  3) DOM-Based XSS
  4) Blind XSS
  5) Parameter Analysis
  6) BAV
  7) Encoder Bypass
  8) Polyglot
  9) Context-aware
 10) Reflection Grep
 11) Header Injection
 12) Static File
 13) MIME Sniffing"
    read -p "Your choice [1-13]: " attack

    FLAGS=""
    [[ "$level" == "1" ]] && FLAGS="--skip-mining-all --timeout 5 -w 50"
    [[ "$attack" == "3" ]] && FLAGS="$FLAGS --deep-domxss"
    [[ "$attack" == "6" ]] && FLAGS="$FLAGS --use-bav"
    [[ "$attack" == "4" && "$mode" == "6" ]] && FLAGS="$FLAGS --blind https://$domain/blind-xss-hook"

    case $mode in
        1) cat urls-with-params-clean.txt | while read url; do dalfox url "$url" $FLAGS | tee -a xss-scan-report.txt; done;;
        2) dalfox file urls-with-params-clean.txt $FLAGS | tee xss-scan-report.txt;;
        3) cat urls-with-params-clean.txt | dalfox pipe $FLAGS | tee xss-scan-report.txt;;
        4) dalfox server;;
        5) dalfox scan --file urls-with-params-clean.txt $FLAGS | tee xss-scan-report.txt;;
        6) dalfox file urls-with-params-clean.txt $FLAGS | tee xss-scan-report.txt;;
    esac

    read -p "📄 Save HTML report? [y/n]: " htmlreport
    if [[ "$htmlreport" == "y" || "$htmlreport" == "Y" ]]; then
        dalfox file urls-with-params-clean.txt --format html -o dalfox-report.html
        echo -e "${GREEN}📄 HTML report saved as dalfox-report.html${NC}"
    fi
else
    echo -e "${YELLOW}⏩ Dalfox testing skipped.${NC}"
fi
echo -ne "${BLUE}[9/9] Recon finished. Ready for Dalfox.${NC}
"
echo -e "${GREEN}✅ بخش شناسایی اولیه کامل شد. می‌تونی تست Dalfox رو اجرا کنی.${NC}"
