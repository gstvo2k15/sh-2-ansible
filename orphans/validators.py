"""Validation of deletion preconditions."""

from clean_orphans.config import ALLOWED_ENV, ALLOWED_REGION


def check_env_and_region(dpi):
    """Return True only if env and region match allowed values."""
    env = dpi.get("env", "").upper()
    region = dpi.get("region", "").upper()

    if env not in ALLOWED_ENV:
        print(f"Skipping {dpi['hostname']}: env not allowed ({env})")
        return False

    if region not in ALLOWED_REGION:
        print(f"Skipping {dpi['hostname']}: region not allowed ({region})")
        return False

    return True