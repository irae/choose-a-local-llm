#!/usr/bin/env python3
"""Fake completion server for the run-watch tests.

Usage: fake-server.py <port> <answer|hang> [hang-seconds]
"""
import json
import sys
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

MODE = sys.argv[2]
HANG = float(sys.argv[3]) if len(sys.argv) > 3 else 3600


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_POST(self):
        length = int(self.headers.get('Content-Length') or 0)
        self.rfile.read(length)
        if MODE == 'hang':
            time.sleep(HANG)
        body = json.dumps({"choices": [{"message": {"content": "ok"}}]}).encode()
        self.send_response(200)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)


HTTPServer(('127.0.0.1', int(sys.argv[1])), Handler).serve_forever()
