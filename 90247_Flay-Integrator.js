// [SHIM_EXTENSION: FLAY_HOOK_v1.0]
// Intercepts sidebar events and yields them to the local Flay_Yields directory

(function() {
    const originalToggle = window.O; // The O function from your Ft component
    window.O = function(payload) {
        if (payload.scenario === "toggleMenu") {
            console.log(`%c[FLAY_YIELD] Conversation identified: ${payload.customData}`, "color: #ff00ff;");
            
            // Trigger the local file write via your VALEX bridge
            window.external.WriteYield(payload.customData); 
        }
        return originalToggle.apply(this, arguments);
    };
})();