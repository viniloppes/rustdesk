#!/usr/bin/env python3
"""Generates an ed25519 key pair in the format hbbs uses (id_ed25519 / id_ed25519.pub).

The public key is chosen without '/' or '+' so it can also go in a file name.
Requires: pip install cryptography
"""
import base64

from cryptography.hazmat.primitives import serialization as s
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

while True:
    key = Ed25519PrivateKey.generate()
    seed = key.private_bytes(s.Encoding.Raw, s.PrivateFormat.Raw, s.NoEncryption())
    pub = key.public_key().public_bytes(s.Encoding.Raw, s.PublicFormat.Raw)
    pub64 = base64.b64encode(pub).decode()
    if "/" not in pub64 and "+" not in pub64:
        break

print("RS_PUB_KEY=" + pub64)
print("RS_PRIV_KEY=" + base64.b64encode(seed + pub).decode())
