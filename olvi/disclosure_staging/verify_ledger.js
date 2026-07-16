/**
 * OMNIBUS Verification Module - JavaScript/Node.js Context
 * Parses and audits local ledger structure metrics.
 */
const fs = require('fs');
const path = require('path');

const ledgerPath = path.join(__dirname, 'triad_specification.json');

try {
    if (!fs.existsSync(ledgerPath)) {
        console.error(`[-] Error: Ledger file not found at ${ledgerPath}`);
        process.exit(1);
    }

    const rawData = fs.readFileSync(ledgerPath, 'utf8');
    const data = JSON.parse(rawData);
    
    console.log("\n================================================================================");
    console.log("[JS-QUERY] LOCAL COMPLIANCE AUDIT VALIDATION RUN");
    console.log("================================================================================");
    
    let scores = [];
    for (const [layer, details] of Object.entries(data.triad_mapping)) {
        console.log(`\nLayer ID:  ${layer.toUpperCase()}`);
        console.log(`Target:    ${details.component}`);
        console.log(`Vuln:      ${details.vulnerability}`);
        console.log(`CVSS v3.1: [${details.cvss_v31}] - Vector: ${details.vector_string}`);
        scores.push(parseFloat(details.cvss_v31));
    }
    
    const avg = scores.reduce((a, b) => a + b, 0) / scores.length;
    console.log("\n--------------------------------------------------------------------------------");
    console.log(`[+] COMPLIANCE REPORT: Aggregate Core Triad Score: ${avg.toFixed(2)}`);
    console.log("================================================================================\n");

} catch (err) {
    console.error(`[-] Exception running JavaScript validation query: ${err.message}`);
    process.exit(1);
}
