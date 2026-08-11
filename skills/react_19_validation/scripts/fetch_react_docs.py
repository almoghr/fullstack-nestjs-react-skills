#!/usr/bin/env python3
import urllib.request
import sys

def fetch_react_llms_txt():
    url = "https://react.dev/llms.txt"
    try:
        # User-Agent is sometimes required to avoid 403 Forbidden from some CDNs
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req) as response:
            content = response.read().decode('utf-8')
            
        print(content)
            
    except Exception as e:
        print(f"Error fetching React docs from {url}: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    fetch_react_llms_txt()
