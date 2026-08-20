from __future__ import annotations

import base64
import os
import re
from collections import OrderedDict

VALID_REGIONS = {"emea", "amer", "apac"}
VALID_ENVS = {"dev", "stg", "prd"}
VALID_LOCATIONS = {"core", "dmzi", "ets", "mzr"}

ATTR_RE = {
    "region": re.compile(r"(?:^|\s)region=([A-Za-z]+)(?:$|\s)"),
    "env": re.compile(r"(?:^|\s)env=([A-Za-z]+)(?:$|\s)"),
    "location": re.compile(r"(?:^|\s)location=([A-Za-z]+)(?:$|\s)"),
}


def _attr(rest, key):
    match = ATTR_RE[key].search(rest)
    return match.group(1).lower() if match else None


def patch_build_groups(payload, product):
    """
    Reproduces the intended logic of generate_product_hosts.sh +
    generate_product_varfiles.sh + generate_varfile.sh.

    Input payload item:
      {
        "path": ".../tomcat.ini",
        "name": "tomcat",
        "content_b64": "..."
      }
    """
    grouped = OrderedDict()

    for source in payload:
        source_name = source["name"]
        text = base64.b64decode(source["content_b64"]).decode("utf-8")

        for raw_line in text.splitlines():
            line = raw_line.strip()
            if not line:
                continue

            parts = line.split(None, 1)
            if len(parts) != 2:
                continue

            host, rest = parts
            region = _attr(rest, "region")
            env = _attr(rest, "env")
            location = _attr(rest, "location")

            if region not in VALID_REGIONS:
                continue
            if env not in VALID_ENVS:
                continue
            if location not in VALID_LOCATIONS:
                continue

            key = (source_name, region, env, location)
            grouped.setdefault(key, []).append(host)

    result = []

    for (source_name, region, env, location), hosts in grouped.items():
        if product == "java":
            host_file = f"java_{source_name}-{region}-{env}-{location}"
        else:
            host_file = f"{product}-{region}-{env}-{location}"

        output_location = "CORE" if location == "mzr" else location.upper()

        result.append(
            {
                "source_product": source_name,
                "region": region,
                "env": env,
                "location": location,
                "output_location": output_location,
                "hosts": hosts,
                "host_file": host_file,
            }
        )

    return result


class FilterModule(object):
    def filters(self):
        return {
            "patch_build_groups": patch_build_groups,
        }
