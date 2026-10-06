"""Vendor the previously audited exact member, without executing package scripts."""
import hashlib
import tarfile
import sys
from pathlib import Path
root = Path(__file__).resolve().parents[1]
if len(sys.argv) != 2:
    raise SystemExit('Usage: python3 script/vendor_mixpanel.py <audited-mixpanel-browser-2.84.0.tgz>')
archive = Path(sys.argv[1])
with tarfile.open(archive) as package:
    member = package.extractfile('package/dist/mixpanel.min.js')
    assert member is not None
    data = member.read()
    assert hashlib.sha256(data).hexdigest() == '1a10e96045c70c048725f81778fa82fbb731513a4876f0e0daa96a57a9bed279'
    (root / 'app/assets/javascripts/mixpanel-2.84.0.min.js').write_bytes(data)
    license_member = package.extractfile('package/LICENSE')
    assert license_member is not None
    license_text = license_member.read()
    (root / 'docs/mixpanel-2.84.0-LICENSE').write_bytes(license_text)
print('Vendored exact audited official member:', len(data), 'bytes')
