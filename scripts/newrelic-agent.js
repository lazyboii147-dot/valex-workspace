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
/*
*/
/*
EOF-METADATA-BEGIN
HASH: 37614bb9bc38664ce15c528145b548625c9070c8c098bf0d928798376dfb419e23a35252362eef22f519e9da21f3dc455e8be3666c8b80a343db77db468e0d84
SIGNATURE: MEQCIGSWwRlmOiScKdrEXPXIpQabKWPU+dusxif5rDyCeUMiAiB1FGcEABsX3Y52kLCoHwJz226UibsvhbjIPdx4vtjaCA==
TIMESTAMP: 2026-06-10T07:04:27Z
FILE: newrelic-agent.js
EOF-METADATA-END
*/
