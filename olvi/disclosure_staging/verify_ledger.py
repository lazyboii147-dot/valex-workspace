#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
OMNIBUS Verification Module - Python Engine
Parses and audits local ledger structure metrics.
"""
import os
import json
import sys

def main():
    ledger_path = os.path.join(os.path.dirname(__file__), 'triad_specification.json')
    
    if not os.path.exists(ledger_path):
        print(f"[-] Error: Ledger file not found at {ledger_path}", file=sys.stderr)
        sys.exit(1)
        
    try:
        with open(ledger_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            
        print("\n================================================================================")
        print("[PYTHON-QUERY] LOCAL COMPLIANCE AUDIT VALIDATION RUN")
        print("================================================================================")
        
        scores = []
        mapping = data.get("triad_mapping", {})
        for layer, details in mapping.items():
            print(f"\nLayer ID:  {layer.upper()}")
            print(f"Target:    {details.get('component')}")
            print(f"Vuln:      {details.get('vulnerability')}")
            print(f"CVSS v3.1: [{details.get('cvss_v31')}] - Vector: {details.get('vector_string')}")
            scores.append(float(details.get('cvss_v31', 0.0)))
            
        if scores:
            avg = sum(scores) / len(scores)
            print("\n--------------------------------------------------------------------------------");
            print(f"[+] COMPLIANCE REPORT: Aggregate Core Triad Score: {avg:.2f}")
            print("================================================================================\n")
            
    except Exception as e:
        print(f"[-] Exception running Python validation query: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
