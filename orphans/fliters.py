"""Orphan VM listing and hostname/fqdn normalization."""

import json


def get_orphans_vms(session, endpoint, middleware_products, ensure_fqdn_fn):
    """Fetch and filter orphan VMs matching middleware products."""
    vm_to_delete = []

    for page in range(1, 11):
        url = endpoint.format(page)
        resp = session.get(url)

        if resp.status_code not in (200, 201):
            print("List orphan error http:", resp.status_code)
            continue

        items = json.loads(resp.text)

        if not items:
            break

        for entry in items:
            if entry["product_name"] in middleware_products:
                fqdn = ensure_fqdn_fn(
                    entry.get("hostname"),
                    entry.get("fqdn")
                )

                vm_to_delete.append({
                    "hostname": entry.get("hostname"),
                    "fqdn": fqdn,
                    "track_id": entry.get("sub_id"),
                    "job_id": entry.get("vanish_job_id"),
                    "provider": entry.get("provider"),
                    "product_name": entry.get("product_name")
                })

    return vm_to_delete


def _ensure_valid_fqdn(self, hostname, fqdn_value):
    """Ensure FQDN is valid, generate if missing or incomplete."""
    if not fqdn_value or "." not in fqdn_value:
        return ".".join([hostname, self.default_dns_domain])
    return fqdn_value
