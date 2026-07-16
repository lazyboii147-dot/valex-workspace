#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <TARGET_PAGE_URL>"
  exit 2
fi

TARGET_PAGE="$1"
ROOT="$(pwd)"

echo "[+] Initializing full security automation environment in $ROOT"
mkdir -p scripts .github/workflows

###############################################
# 1. package.json
###############################################
cat > package.json <<'JSON'
{
  "name": "security-ci-suite",
  "version": "1.0.0",
  "description": "Automated SRI verification + Marketo + New Relic analysis",
  "main": "ci-verify-sri.js",
  "scripts": {
    "verify-sri": "node ci-verify-sri.js"
  },
  "dependencies": {
    "jsdom": "^22.1.0"
  }
}
JSON

###############################################
# 2. Marketo submission logic
###############################################
cat > scripts/marketo-submit.js <<'JS'
/* Marketo form submission hashing logic (merged) */
function marketoSubmit(a, d, C, c, o, p, Q, x, y, R, T, P, q, g, e, n) {
  var h = d.getValues();
  if (window.Munchkin) try { window.Munchkin.createTrackingCookie(true); } catch (_) {}

  var j = o.parse(C, true).query;
  var k = p.parse(document.cookie);
  var l = o.parse(a.action).hostname;
  var m = (l ? "//" + l : "") + c.formSubmitPath;

  if (location.hostname === l) {
    m = c.formSubmitPath;
    l = location.hostname;
  }

  var r = "json";
  var s = "POST";

  if (h._mkt_trk === undefined) h._mkt_trk = k._mkto_trk;
  h.formVid = a.Vid;

  if (j.mkt_tok && h.mkt_tok === undefined) h.mkt_tok = j.mkt_tok;

  var t = Q(k);
  if (t) h.MarketoSocialSyndicationId = t;

  h._mktoReferrer = C;

  var u = [];
  var w = [];

  var z = function(obj) {
    var count = 0;
    e.each(obj, function(key, val) {
      if (count >= 20) return;
      u.push(val);
      w.push(key);
      count++;
    });
  };

  z(h);

  h.checksumFields = w.join(",");
  h.checksum = x("sha256").update(u.join("|")).digest("hex");

  if (y.captchaToken) h.captchaToken = y.captchaToken;

  var A = n.stringify(R(h));

  var B = function(resp) {
    var url = T(resp);
    if (P(h, url) !== false) {
      q.removeCookieAllDomains("_mkto_purl");
      location.href = url;
    }
  };

  var F = function(err) {
    var msg = a.formSubmitFailedMsg || "Submission failed, please try again later.";
    if (err.errorType === "invalid") {
      if (err.invalidInputMsg) err.invalidInputMsg = f(err.invalidInputMsg);
      msg = err.invalidInputMsg || a.invalidInputMsg || "Invalid input";
    }

    if (y.submitButton) {
      var btn = y.submitButton.find("button");
      btn.removeAttr("disabled");
      btn.html(a.ButtonText || a.SubmitLabel || "Submit");
      y.validation.showError(btn, msg);
    }
  };

  var G = {
    type: s,
    data: A,
    dataType: r,
    url: m,
    success: function(resp) {
      if (resp.error) return F(resp);
      if (resp.formId) return B(resp);
    },
    error: F
  };

  if (l && l !== location.hostname) {
    if (b.postmessage && b.json) v.send(G);
    else {
      G.dataType = "jsonp";
      G.submitUrl += "?callback=?";
      G.type = "GET";
      G.error = g;
      e.ajax(G);
    }
  } else {
    G.error = g;
    e.ajax(G);
  }
}
JS

###############################################
# 3. New Relic agent loader module
###############################################
cat > scripts/newrelic-agent.js <<'JS'
/* New Relic SPA agent loader (from user snippet) */
class NewRelicAgent extends e.d {
  constructor(e) {
    super();
    if (!f.gm) return (0, h.R)(21);

    this.features = {};
    (0, T.bQ)(this.agentIdentifier, this);
    this.desiredFeatures = new Set(e.features || []);
    this.desiredFeatures.add(E);

    (0, n.j)(this, e, e.loaderType || "agent");

    const self = this;

    (0, c.Y)(a.cD, function(key, val, flag=false) {
      if (typeof key === "string") {
        if (["string","number","boolean"].includes(typeof val) || val === null)
          return (0, c.U)(self, key, val, a.cD, flag);
        (0, h.R)(40, typeof val);
      } else (0, h.R)(39, typeof key);
    }, self);

    this.run();
  }

  get config() {
    return {
      info: this.info,
      init: this.init,
      loader_config: this.loader_config,
      runtime: this.runtime
    };
  }

  get api() {
    return this;
  }

  run() {
    try {
      const enabled = {};
      r.forEach(k => enabled[k] = !!this.init[k]?.enabled);

      const list = [...this.desiredFeatures];
      list.sort((a,b) => t.P3[a.featureName] - t.P3[b.featureName]);

      list.forEach(feature => {
        if (!enabled[feature.featureName] && feature.featureName !== t.K7.pageViewEvent)
          return;

        const deps = (function(fName) {
          switch (fName) {
            case t.K7.ajax: return [t.K7.jserrors];
            case t.K7.sessionTrace: return [t.K7.ajax, t.K7.pageViewEvent];
            case t.K7.sessionReplay: return [t.K7.sessionTrace];
            case t.K7.pageViewTiming: return [t.K7.pageViewEvent];
            default: return [];
          }
        })(feature.featureName).filter(d => !(d in this.features));

        if (deps.length > 0)
          (0, h.R)(36, { targetFeature: feature.featureName, missingDependencies: deps });

        this.features[feature.featureName] = new feature(this);
      });

    } catch (err) {
      (0, h.R)(22, err);
      for (const f in this.features) this.features[f].abortHandler?.();
      const ctx = (0, T.Zm)();
      delete ctx.initializedAgents[this.agentIdentifier]?.features;
      delete this.sharedAggregator;
      return ctx.ee.get(this.agentIdentifier).abort(), false;
    }
  }
}
JS

###############################################
# 4. compute-sri.js
###############################################
cat > scripts/compute-sri.js <<'JS'
#!/usr/bin/env node
const https = require("https");
const { createHash } = require("crypto");

function fetchBuffer(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return resolve(fetchBuffer(new URL(res.headers.location, url).toString()));

      if (res.statusCode !== 200)
        return reject(new Error(`HTTP ${res.statusCode} for ${url}`));

      const chunks = [];
      res.on("data", c => chunks.push(c));
      res.on("end", () => resolve(Buffer.concat(chunks)));
    }).on("error", reject);
  });
}

(async () => {
  const url = process.argv[2];
  if (!url) {
    console.error("Usage: compute-sri.js <url>");
    process.exit(2);
  }
  try {
    const buf = await fetchBuffer(url);
    const hash = createHash("sha512").update(buf).digest("base64");
    console.log(`sha512-${hash}`);
  } catch (err) {
    console.error("Fetch failed:", err.message);
    process.exit(1);
  }
})();
JS
chmod +x scripts/compute-sri.js

###############################################
# 5. ci-verify-sri.js
###############################################
cat > ci-verify-sri.js <<'JS'
#!/usr/bin/env node
const https = require("https");
const { createHash } = require("crypto");
const { JSDOM } = require("jsdom");

if (process.argv.length < 3) {
  console.error("Usage: node ci-verify-sri.js <page-url>");
  process.exit(2);
}

const pageUrl = process.argv[2];

function fetchBuffer(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      if (res.statusCode >= 300 && res.statusCode < 400 && res.headers.location)
        return resolve(fetchBuffer(new URL(res.headers.location, url).toString()));

      if (res.statusCode !== 200)
        return reject(new Error(`HTTP ${res.statusCode} for ${url}`));

      const chunks = [];
      res.on("data", c => chunks.push(c));
      res.on("end", () => resolve(Buffer.concat(chunks)));
    }).on("error", reject);
  });
}

function computeSha512Base64(buffer) {
  return createHash("sha512").update(buffer).digest("base64");
}

async function fetchText(url) {
  const buf = await fetchBuffer(url);
  return buf.toString("utf8");
}

(async () => {
  console.log("Fetching:", pageUrl);
  const html = await fetchText(pageUrl);
  const dom = new JSDOM(html, { url: pageUrl });
  const doc = dom.window.document;

  const scripts = Array.from(doc.querySelectorAll("script[src]")).map(s => ({
    src: new URL(s.getAttribute("src"), pageUrl).toString(),
    integrity: s.getAttribute("integrity")
  }));

  const missing = [];
  const mismatched = [];
  const ok = [];

  for (const s of scripts) {
    const isExternal = new URL(s.src).origin !== new URL(pageUrl).origin;

    if (!isExternal) continue;

    if (!s.integrity) {
      missing.push(s.src);
      continue;
    }

    const token = s.integrity.split(/\s+/).find(t => t.startsWith("sha512-"));
    if (!token) {
      mismatched.push({ src: s.src, reason: "no sha512 token" });
      continue;
    }

    const expected = token.replace("sha512-", "");

    try {
      const buf = await fetchBuffer(s.src);
      const computed = computeSha512Base64(buf);
      if (computed === expected) ok.push(s.src);
      else mismatched.push({ src: s.src, expected, computed });
    } catch (err) {
      mismatched.push({ src: s.src, reason: err.message });
    }
  }

  console.log("OK:", ok.length);
  console.log("Missing integrity:", missing.length);
  console.log("Mismatched:", mismatched.length);

  if (missing.length || mismatched.length) process.exit(1);
  process.exit(0);
})();
JS
chmod +x ci-verify-sri.js

###############################################
# 6. GitHub Actions workflow
###############################################
cat > .github/workflows/sri-verify.yml <<YML
name: Verify SRI for external scripts
on:
  push:
  pull_request:
jobs:
  verify-sri:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm install
      - run: node ci-verify-sri.js "${TARGET_PAGE}"
YML

###############################################
# 7. Install dependencies
###############################################
echo "[+] Installing Node dependencies..."
npm install

###############################################
# 8. Initial SRI verification
###############################################
echo "[+] Running initial SRI verification..."
node ci-verify-sri.js "$TARGET_PAGE" || true

echo "[✓] Bootstrap complete."
echo "All modules created:"
echo "  - scripts/marketo-submit.js"
echo "  - scripts/newrelic-agent.js"
echo "  - scripts/compute-sri.js"
echo "  - ci-verify-sri.js"
echo "  - .github/workflows/sri-verify.yml"
echo "  - package.json"
/*
*/
/*
EOF-METADATA-BEGIN
HASH: fb455c00ad58c041476897d0ac5a60ed6e05b18ae7987530ed135b12ed425fa2e61169be368b73984b624df1f67522b2e8fda3e938ddb0f62ed40fb5f0a45269
SIGNATURE: MEYCIQC7nZLSl8NQT37/nUQXVjuetZgd4u/jb0sH5WW9jz+gJgIhAJRHwo2/vZyMEq0KkzzemMxFUXTzi5gdz3mTKy2uDRgK
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: bootstrap.sh
EOF-METADATA-END
*/
