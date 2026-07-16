#!/usr/bin/env python3
# ==============================================================================
# TITLE:        VALEX SECURED INTERFACE ENGINE
# AUTHOR:       Enrique B. Gonzalez III (CajaCl34r / CL34RBoXx)
# DATE:         2026-06-01
# DESCRIPTION:  Appends explicit Content-Security-Policy parameters and 
#               Cross-Origin resource protections to silence browser noise.
# ==============================================================================

import sys
import os
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080
PROCESSOR_SCRIPT = "./process_audio.sh"

class SecureOmnibusGatewayHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        parsed_url = urllib.parse.urlparse(self.path)
        query_params = urllib.parse.parse_qs(parsed_url.query)
        
        print(f"[RAW TRANSACTION] Path: {self.path}", flush=True)
        status_msg = "UNKNOWN_OR_INERT_PARAMETER_LAYER"
        
        if 'target' in query_params:
            target_path = query_params['target'][0]
            print(f"[PARSER SUCCESS] Isolated File Target: {target_path}", flush=True)
            
            if os.path.exists(target_path):
                print(f"[PIPELINE EXECUTE] Dispatching verification for {target_path}...", flush=True)
                os.system(f"{PROCESSOR_SCRIPT} \"{target_path}\"")
                status_msg = "TARGET_VERIFICATION_DISPATCHED"
            else:
                status_msg = "TARGET_PATH_NOT_FOUND_ON_HOST"

        # --- RESPOND WITH CORRECTED SECURITY HEADERS ---
        self.send_response(200)
        self.send_header("Content-Type", "text/plain; charset=utf-8")
        
        # Inject explicit CSP to allow localized test strings and suppress inline-script/hash warnings
        self.send_header("Content-Security-Policy", 
                         "default-src 'self'; "
                         "script-src 'self' 'unsafe-inline' 'unsafe-hashes' 'sha256-IWu8eKPFpwBlPtvm+lmwBh1mAdRu4b2jd4cGC9eFA54='; "
                         "style-src 'self' 'unsafe-inline';")
        
        # Satisfy Opaque Response Blocking (ORB) and Cross-Origin Resource Policy (CORP) definitions
        self.send_header("Cross-Origin-Resource-Policy", "cross-origin")
        self.send_header("X-Content-Type-Options", "nosniff")
        self.end_headers()
        
        response_body = f"""==================================================
VALEX SECURED LOCAL ENDPOINT RESPONSE
==================================================
STATUS:      {status_msg}
TRANSACTION: COMPLETED
PAYLOAD:     {self.path}
==================================================\n"""
        self.wfile.write(response_body.encode('utf-8'))

    def log_message(self, format, *args):
        # Prevent loop logs from bleeding into standard console tracking outputs
        return

if __name__ == '__main__':
    print(f"[+] VALEX Secure Engine actively listening on http://127.0.0.1:{PORT}", flush=True)
    server = HTTPServer(('127.0.0.1', PORT), SecureOmnibusGatewayHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[-] Shutting down secure interface interfaces safely.", flush=True)
        server.server_close()
/*
*/
/*
EOF-METADATA-BEGIN
HASH: de34391789b6eff536f6b2f95caee0584c8015f92afa9b5db764ebc9c977f1c51fecb084f567f7adfd66521bebbd2cb8fccfbf1b82302f36ddf2d5c4798cfe64
SIGNATURE: MEUCIAQxa+axi8AyqdtMW79ePHxywV7Typvm5VRUNejo8bE5AiEA6B21UTRVrwcGdqZFkZ99ubOU6w6NZkV4IsOhZ2sgxzU=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: omnibus_server_secure.py
EOF-METADATA-END
*/
