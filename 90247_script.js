// ACATL Remediation Logic
const output = document.getElementById('output-stream');

function log(message, className = "") {
    const p = document.createElement('p');
    p.textContent = `[${new Date().toLocaleTimeString()}] ${message}`;
    if (className) p.className = className;
    output.appendChild(p);
    output.scrollTop = output.scrollHeight;
}

// 1. Intercept Global Eval (Manual Override Logic)
const originalEval = window.eval;
window.eval = function(input) {
    if (input.includes("atob") || input.includes("exploit")) {
        log("REMEDIATION BLOCK: Unauthorized RCE vector detected.", "blocked");
        return null;
    }
    return originalEval(input);
};

// 2. Simulated Injection Test
function testNeutralization() {
    const input = document.getElementById('payload-input').value;
    log(`Testing payload: ${input}...`);
    
    try {
        eval(input);
    } catch (e) {
        log(`CSP/TrustedTypes Intervention: ${e.message}`, "blocked");
    }
}

log("Acatl Interface stabilized. Ready for input.");
