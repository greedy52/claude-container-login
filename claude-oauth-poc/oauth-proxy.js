#!/usr/bin/env node
/**
 * HTTP proxy for OAuth callbacks with IPv6 support
 * Silent mode - all output goes to log file only
 */

const http = require('http');
const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs');
const execAsync = promisify(exec);

const PROXY_PORT = 8080;
const LOG_FILE = '/workspace/oauth-proxy.log';

// Initialize log file
fs.writeFileSync(LOG_FILE, `[${new Date().toISOString()}] OAuth HTTP proxy starting...\n`);

function log(message) {
  const timestamp = new Date().toTimeString().split(' ')[0];
  const logLine = `[${timestamp}] ${message}\n`;
  fs.appendFileSync(LOG_FILE, logLine);
  // No console output - silent mode
}

async function findClaudePort() {
  try {
    const { stdout } = await execAsync('ss -tlnp 2>/dev/null | grep LISTEN');
    const lines = stdout.split('\n');

    for (const line of lines) {
      const match = line.match(/:([3-5]\d{4})/);
      if (match) {
        const port = parseInt(match[1]);
        if (port !== PROXY_PORT) {
          const isIPv6 = line.includes('::');
          return { port, isIPv6 };
        }
      }
    }
  } catch (err) {
    log(`Error finding port: ${err.message}`);
  }
  return null;
}

const server = http.createServer(async (req, res) => {
  log(`>>> ${req.method} ${req.url}`);

  const target = await findClaudePort();

  if (!target) {
    log('ERROR: Could not find Claude OAuth server port');
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('OAuth server not found');
    return;
  }

  const targetHost = target.isIPv6 ? '::1' : '127.0.0.1';
  log(`>>> Proxying to ${targetHost}:${target.port}`);

  const proxyReq = http.request({
    hostname: targetHost,
    port: target.port,
    path: req.url,
    method: req.method,
    headers: {
      ...req.headers,
      host: req.headers.host || `localhost:${target.port}`
    },
    family: target.isIPv6 ? 6 : 4
  }, (proxyRes) => {
    log(`<<< Response: ${proxyRes.statusCode}`);
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (err) => {
    log(`!!! Error: ${err.message}`);
    res.writeHead(502, { 'Content-Type': 'text/plain' });
    res.end('Proxy error');
  });

  req.pipe(proxyReq);
});

server.listen(PROXY_PORT, '::', () => {
  log(`Listening on port ${PROXY_PORT} (IPv4 and IPv6)`);
});

// Suppress any unhandled errors to keep terminal clean
process.on('uncaughtException', (err) => {
  log(`Uncaught exception: ${err.message}`);
});

process.on('unhandledRejection', (err) => {
  log(`Unhandled rejection: ${err}`);
});
