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
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 1aba0c87bcfc0445a8d2a5062198dd5131851146671d16d356c63edd12a32d64af9572c7f45c6a6ac03d3dc7c2dbf0876f3e16e40bc2646fbf60467c301bcf45
SIGNATURE: MEUCIQDh6+qf0dSuCd1GAelIZv1SSbyp6ybeK95PC5LBBG71pwIgY9v7jPceK63CyBRNrhu1renbt+bPtGzOvHmfpPAUnxQ=
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: marketo-submit.js
EOF-METADATA-END
*/
