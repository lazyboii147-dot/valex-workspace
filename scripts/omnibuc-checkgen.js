// omnibus-checkgen.js
// Node 16+
// Usage: node omnibus-checkgen.js path/to/omnibus.csv

const fs = require('fs');
const path = require('path');

function parseCsv(text) {
  const lines = text.split(/\r?\n/).filter(Boolean);
  if (lines.length === 0) return [];
  const header = lines.shift().split(',').map(h => h.trim());
  return lines.map(line => {
    // simple CSV parse that handles quoted fields with commas
    const cols = [];
    let cur = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
      const ch = line[i];
      if (ch === '"' && line[i+1] === '"') { cur += '"'; i++; continue; }
      if (ch === '"') { inQuotes = !inQuotes; continue; }
      if (ch === ',' && !inQuotes) { cols.push(cur.trim()); cur = ''; continue; }
      cur += ch;
    }
    cols.push(cur.trim());
    const obj = {};
    header.forEach((h, idx) => obj[h] = (cols[idx] || '').trim());
    return obj;
  });
}

function suggestCommands(row) {
  const id = row['ID'] || row['Id'] || row['id'];
  const module = row['Operational Module'] || row['OperationalModule'] || row['Module'];
  const anchor = row['Forensic Anchor Point (Verification)'] || row['Forensic Anchor Point'] || row['Verification'] || '';

  const suggestions = [];

  // heuristics for common anchors
  if (/icacls/i.test(anchor) || /NTFS/i.test(module)) {
    suggestions.push({
      type: 'Windows',
      cmd: `icacls "C:\\Path\\To\\Target"  // replace with actual path; verify (F) for target group`
    });
    suggestions.push({ type: 'Note', cmd: 'Capture output to file: icacls "C:\\Path" /save acl_dump.txt' });
  }

  if (/KfmForceWindowsDisplayLanguage|OneDrive/i.test(anchor + module)) {
    suggestions.push({ type: 'Windows', cmd: `reg query "HKCU\\Software\\Microsoft\\OneDrive" /v KfmForceWindowsDisplayLanguage` });
    suggestions.push({ type: 'Manual', cmd: 'Open OneDrive Settings -> Choose Folders -> capture sync status screenshot' });
  }

  if (/manage-bde/i.test(anchor) || /BitLocker/i.test(module)) {
    suggestions.push({ type: 'Windows', cmd: `manage-bde -status` });
    suggestions.push({ type: 'Windows', cmd: `manage-bde -protectors -get C:  // collect recovery key metadata` });
  }

  if (/gpresult/i.test(anchor) || /Group Policy|GPO/i.test(module)) {
    suggestions.push({ type: 'Windows', cmd: `gpresult /h gpresult_${id}.html` });
    suggestions.push({ type: 'Windows', cmd: `secedit /export /cfg current_gpo_${id}.inf` });
  }

  if (/SMB 3.0|Azure Storage|Secure Transfer/i.test(anchor + module)) {
    suggestions.push({ type: 'Azure', cmd: `az storage account show --name <acct> --resource-group <rg> --query "enableHttpsTrafficOnly"` });
    suggestions.push({ type: 'Azure', cmd: `az storage account show --name <acct> --resource-group <rg> --query "sku.name"` });
  }

  if (/SSTP|VPN|MSCHAPv2/i.test(anchor + module)) {
    suggestions.push({ type: 'Network', cmd: `netstat -an | findstr ":443"  // confirm SSTP listener` });
    suggestions.push({ type: 'Network', cmd: `Review VPN server logs for MSCHAPv2 handshake entries` });
  }

  if (/Ticket|Issue Trax|Ticket ID/i.test(anchor + module)) {
    suggestions.push({ type: 'Process', cmd: `Ensure ticket contains: ID, remediation timestamp, analyst signature` });
  }

  if (/Get-NetFirewallProfile|New-NetFirewallRule|Windows Firewall/i.test(anchor + module)) {
    suggestions.push({ type: 'PowerShell', cmd: `Get-NetFirewallProfile -Name Public | Format-List` });
    suggestions.push({ type: 'PowerShell', cmd: `Get-NetFirewallRule -PolicyStore ActiveStore | Where-Object { $_.DisplayName -like '*YourApp*' }` });
  }

  if (/fDenyTSConnections|Remote Desktop|RDP/i.test(anchor + module)) {
    suggestions.push({ type: 'Registry', cmd: `reg query "HKLM\\SYSTEM\\CurrentControlSet\\Control\\Terminal Server" /v fDenyTSConnections` });
    suggestions.push({ type: 'PowerShell', cmd: `Get-LocalGroupMember -Group "Remote Desktop Users"` });
  }

  if (/vssadmin|shadowstorage|System Protection/i.test(anchor + module)) {
    suggestions.push({ type: 'Windows', cmd: `vssadmin list shadowstorage` });
    suggestions.push({ type: 'EventLog', cmd: `wevtutil qe System /q:"*[System[(EventID=8193)]]" /f:text /c:20` });
  }

  // fallback: echo the anchor as a manual verification hint
  if (suggestions.length === 0) {
    suggestions.push({ type: 'Manual', cmd: `Verify: ${anchor}` });
  }

  return { id, module, anchor, suggestions };
}

function main() {
  const csvPath = process.argv[2];
  if (!csvPath) {
    console.error('Usage: node omnibus-checkgen.js path/to/omnibus.csv');
    process.exit(2);
  }
  const text = fs.readFileSync(path.resolve(csvPath), 'utf8');
  const rows = parseCsv(text);
  const results = rows.map(r => suggestCommands(r));

  // print JSON
  console.log('=== JSON OUTPUT ===');
  console.log(JSON.stringify(results, null, 2));

  // print human checklist
  console.log('\n=== CHECKLIST ===\n');
  results.forEach(r => {
    console.log(`ID ${r.id}  -  ${r.module}`);
    console.log(`  Anchor  : ${r.anchor}`);
    r.suggestions.forEach(s => {
      console.log(`  [${s.type}] ${s.cmd}`);
    });
    console.log('');
  });
}

main();
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 8302c5fbd31b4d73460aac2594202a30bd7fea9e05faaf268ba45e9c86f584f25fbe7698504507c32196f42659a51341b7f1f33ae3bf2d4082113ac1ad89d807
SIGNATURE: MEQCIC7gcNvq15zAIUvufMmb4h9DhH3ZyE2CBcNNgnLTq5J7AiBtvQ+o7vzRWur1KOUsOmem9DwpjsbXP676oLZmp1eJZg==
TIMESTAMP: 2026-06-10T07:04:26Z
FILE: omnibuc-checkgen.js
EOF-METADATA-END
*/
