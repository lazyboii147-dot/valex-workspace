/* DOMPurify strict configuration placeholder. */
const STRICT_URI_RE = /^(https?:)\/\//i;
DOMPurify.setConfig({
  ALLOW_UNKNOWN_PROTOCOLS: false,
  ALLOWED_URI_REGEXP: STRICT_URI_RE,
  ADD_DATA_URI_TAGS: [],
  SAFE_FOR_TEMPLATES: true,
  FORBID_ATTR: ['on*', 'style'],
  FORBID_TAGS: ['script', 'template', 'iframe', 'object', 'embed'],
  USE_PROFILES: { html: true, svg: false, svgFilters: false, mathMl: false },
  RETURN_TRUSTED_TYPE: true,
  SANITIZE_DOM: true,
  SANITIZE_NAMED_PROPS: true,
  KEEP_CONTENT: true
});
