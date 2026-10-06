#!/usr/bin/env python3
"""Focused stdlib tests; no Docker, provider, Rails or browser requests."""
import importlib.machinery
from pathlib import Path
import unittest
from unittest.mock import patch

preview = importlib.machinery.SourceFileLoader(
    "recovery_preview", str(Path(__file__).resolve().parents[1] / "bin/recovery-preview")
).load_module()


class RecoveryPreviewTest(unittest.TestCase):
    def test_sitemap_paths_never_include_production_hosts(self):
        paths = preview.routes()
        self.assertEqual(24, len(paths))
        self.assertTrue(all(p.startswith("/") and ":" not in p for p in paths))

    def test_non_loopback_fails_before_any_docker_operation(self):
        with patch.dict(preview.os.environ, {"RECOVERY_PREVIEW_HOST": "0.0.0.0"}):
            with self.assertRaisesRegex(RuntimeError, "127.0.0.1"):
                preview.preflight()

    def test_inherited_provider_configuration_fails_closed(self):
        with patch.dict(preview.os.environ, {"APP_HOST": "production.invalid"}, clear=True):
            with self.assertRaisesRegex(RuntimeError, "Unset inherited"):
                preview.preflight()

    def test_remote_docker_override_fails_before_docker_operation(self):
        with patch.dict(preview.os.environ, {"DOCKER_HOST": "tcp://remote.invalid:2375"}, clear=True):
            with self.assertRaisesRegex(RuntimeError, "DOCKER_HOST"):
                preview.preflight()

    def test_external_css_import_is_removed_only_from_response(self):
        css = b"@import url('https://fonts.example.invalid/x'); body{color:red}"
        safe = preview.filter_body(css, "text/css")
        self.assertNotIn(b"https://", safe)
        self.assertIn(b"body{color:red}", safe)
        self.assertIn(b"https://", css)

    def test_navigation_and_forms_are_disabled(self):
        html = b'<head></head><a href="https://production.invalid">x</a><a href="/sobre.html">s</a><form action="https://production.invalid">'
        safe = preview.filter_body(html, "text/html")
        self.assertNotIn(b"https://", safe)
        self.assertIn(b'href="/sobre.html"', safe)
        self.assertIn(b"stopImmediatePropagation", safe)
        self.assertIn("form-action 'none'", preview.CSP)

    def test_asset_traversal_and_private_routes_are_blocked(self):
        for path in ("/assets/../bookings/availability", "/assets/%2e%2e/bookings", "/entrar", "/checkout/success"):
            self.assertFalse(preview.public_path(path))
        self.assertTrue(preview.public_path("/assets/application-123.js"))

    def test_inherited_exception_boundary(self):
        self.assertEqual(15, len(preview.EXCLUDED))
        self.assertIn("config/credentials.yml.enc", preview.EXCLUDED)
        self.assertIn(".kamal/secrets", preview.EXCLUDED)


if __name__ == "__main__":
    unittest.main()
