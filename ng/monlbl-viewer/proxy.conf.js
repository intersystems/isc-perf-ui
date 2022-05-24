const PROXY_CONFIG = {
    "/api/*": {
      target: "http://localhost:52773/csp/user/monlbl-viewer",
      secure: false,
      logLevel: "debug",
      changeOrigin: true,
    },
  };
  
  module.exports = PROXY_CONFIG;