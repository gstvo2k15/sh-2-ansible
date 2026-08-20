"""Configuration module to read environment variables and constants."""

import os


DRY_RUN = os.environ.get("DRY_RUN", "true").lower() != "false"

USERNAME = os.environ.get("VANISH_USER")
PASSWORD = os.environ.get("VANISH_PASS")
CAPSULE_API_KEY = os.environ.get("CAPSULE_API_KEY")

TOKEN_URL = (
    "https://robotic-auth.cib.echonet/auth/realms/production/"
    "protocol/openid-connect/token"
)

ALLOWED_ENV = "DEV"
ALLOWED_REGION = "EMEA"

VANISH_BEARER_TOKEN = os.environ.get("VANISH_BEARER_TOKEN", "")


if not USERNAME or not PASSWORD or not CAPSULE_API_KEY:
    raise RuntimeError("Missing required environment variables.")