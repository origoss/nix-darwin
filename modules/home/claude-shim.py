#!/usr/bin/env python3
"""Sanitizing reverse-proxy: Claude Code -> omlx.

omlx 0.3.12's /v1/messages rejects any message whose role is not user/assistant
(HTTP 422). Claude Code sometimes puts a 'system'-role message inside the
messages array. This shim lifts such messages out into the top-level `system`
field before forwarding to omlx.

Usage: claude-shim.py <listen_port> <upstream_port>
"""
import json
import sys
import urllib.request
import urllib.error
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

LISTEN_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8000
UPSTREAM = f"http://127.0.0.1:{int(sys.argv[2]) if len(sys.argv) > 2 else 8001}"
LOGFILE = "/Users/eja/.omlx-shim.log"
_logged_once = False


def _log(msg):
    with open(LOGFILE, "a") as f:
        f.write(msg + "\n")


def _text_of(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return "\n".join(
            b.get("text", "")
            for b in content
            if isinstance(b, dict) and b.get("type") == "text"
        )
    return ""


def _merge_system(existing, extra):
    if not extra:
        return existing
    if existing is None:
        return extra
    if isinstance(existing, str):
        return existing + "\n\n" + extra
    if isinstance(existing, list):
        return existing + [{"type": "text", "text": extra}]
    return existing


def sanitize(payload):
    msgs = payload.get("messages")
    if not isinstance(msgs, list):
        return payload, 0
    kept, extracted = [], []
    for m in msgs:
        if isinstance(m, dict) and m.get("role") not in ("user", "assistant"):
            extracted.append(_text_of(m.get("content")))
        else:
            kept.append(m)
    if extracted:
        payload["messages"] = kept
        payload["system"] = _merge_system(
            payload.get("system"), "\n\n".join(t for t in extracted if t)
        )
    return payload, len(extracted)


class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, *a):
        pass

    def _proxy(self):
        global _logged_once
        length = int(self.headers.get("Content-Length", 0) or 0)
        body = self.rfile.read(length) if length else b""

        if body and "application/json" in self.headers.get("Content-Type", ""):
            try:
                payload = json.loads(body)
                if not _logged_once and isinstance(payload.get("messages"), list):
                    _logged_once = True
                    _log("FIRST REQUEST roles: "
                         + json.dumps([m.get("role") for m in payload["messages"]
                                       if isinstance(m, dict)]))
                payload, n = sanitize(payload)
                if n:
                    body = json.dumps(payload).encode()
            except (ValueError, TypeError):
                pass

        headers = {k: v for k, v in self.headers.items()
                   if k.lower() not in ("host", "content-length", "connection")}
        headers["Content-Length"] = str(len(body))
        req = urllib.request.Request(
            UPSTREAM + self.path, data=body if body else None,
            headers=headers, method=self.command,
        )
        try:
            resp = urllib.request.urlopen(req, timeout=3000)
        except urllib.error.HTTPError as e:
            resp = e
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(str(e).encode())
            return

        data = resp.read()
        self.send_response(resp.status)
        for k, v in resp.headers.items():
            if k.lower() not in ("transfer-encoding", "connection", "content-length"):
                self.send_header(k, v)
        self.send_header("Content-Length", str(len(data)))
        self.send_header("Connection", "close")
        self.end_headers()
        self.wfile.write(data)

    do_GET = do_POST = do_DELETE = do_PUT = _proxy


if __name__ == "__main__":
    print(f"claude-shim listening :{LISTEN_PORT} -> {UPSTREAM}", flush=True)
    ThreadingHTTPServer(("127.0.0.1", LISTEN_PORT), Handler).serve_forever()
