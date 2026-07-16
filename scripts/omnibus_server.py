import sys
import os
import urllib.parse
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = int(sys.argv[1])
PROCESSOR_SCRIPT = "./process_audio.sh"

class OmnibusGatewayHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        # Decode the URL pathway parameters safely
        parsed_url = urllib.parse.urlparse(self.path)
        query_params = urllib.parse.parse_qs(parsed_url.query)
        
        # Log request to server stdout (captured by bash log)
        print(f"[RAW TRANSACTION] Path: {self.path}", flush=True)
        
        # Check for the specified target file and payload elements
        if 'target' in query_params:
            target_path = query_params['target'][0]
            print(f"[PARSER SUCCESS] Isolated File Target: {target_path}", flush=True)
            
            # If the XIPE report audio file exists, trigger the internal processor script
            if os.path.exists(target_path):
                print(f"[PIPELINE EXECUTE] Dispatching verification for {target_path}...", flush=True)
                os.system(f"{PROCESSOR_SCRIPT} \"{target_path}\"")
                status_msg = "TARGET_VERIFICATION_DISPATCHED"
            else:
                print(f"[PIPELINE WARN] Path registered but not found on host: {target_path}", flush=True)
                status_msg = "TARGET_PATH_NOT_FOUND_ON_HOST"
        else:
            status_msg = "UNKNOWN_OR_INERT_PARAMETER_LAYER"

        # Serve a structured text tracking response back to the collector engine
        self.send_response(200)
        self.send_header("Content-type", "text/plain")
        self.end_headers()
        
        response_body = f"""==================================================
VALEX LOCAL ENDPOINT RESPONSE
==================================================
STATUS:      {status_msg}
TRANSACTION: COMPLETED
PAYLOAD:     {self.path}
==================================================\n"""
        self.wfile.write(response_body.encode('utf-8'))

    def log_message(self, format, *args):
        # Suppress standard verbose noise to keep terminal tracking clear
        return

if __name__ == '__main__':
    print(f"[+] VALEX Engine actively listening on http://localhost:{PORT}", flush=True)
    server = HTTPServer(('127.0.0.1', PORT), OmnibusGatewayHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[-] Shutting down service engine interfaces safely.", flush=True)
        server.server_close()
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 698d832310f17998cf2c420b5671eb453418c109cc9a03b07bb337256ab7d3fe78845e627db027f5e167c76da69d086b2ad18970084d1de979896786a2dd58e3
SIGNATURE: MEUCIQCKQ4qttyg4z/kgT1QWb4+WDcSKKIVLRWyi9ULN10pviAIgAeKvNircEVqQlvnH4Gy1cGyWE+7JCX7ORTCJuVeK6Gw=
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: omnibus_server.py
EOF-METADATA-END
*/
