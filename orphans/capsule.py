"""Module to fetch and enrich VM data from Capsule API."""

import json
import re


def get_capsule_info(params):
    """Fetch metadata from Capsule and complete missing fields."""
    session = params['session']
    capsule_url = params['capsule_url']
    api_key = params['api_key']
    hostname = params['hostname']
    infer_country_fn = params['infer_country_fn']
    infer_platform_fn = params['infer_platform_fn']

    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "x-apikey": api_key
    }

    resp = session.get(capsule_url.format(hostname), headers=headers)
    data = json.loads(resp.text)

    try:
        parsed = json.loads(resp.text)
        print(f"{hostname}; capsule response:")
        print(json.dumps(parsed, indent=2))
    except Exception:
        print(f"{hostname}; raw capsule response (unparsed): {resp.text}")

    if not data:
        print(f"{hostname}; No capsule info")
        return None

    product_name = data[0]['product_name']
    vm_info = data[0]['vm_info'][0]
    dpi = next((d for d in data[0]['dpi'] if d['hostname'] == hostname), None)

    if not dpi:
        return None

    if 'country' not in dpi:
        dpi['country'] = infer_country_fn(hostname)

    platform_object = dpi.get('platform_object')
    if not platform_object:
        platform_object = infer_platform_fn(product_name)
    elif platform_object.lower() == 'unix':
        platform_object = infer_platform_fn(product_name)

    dpi['platform_object'] = platform_object

    if not dpi.get('domain'):
        if re.search(r'^eur|mac', hostname, re.IGNORECASE):
            dpi['domain'] = 'euro'
        else:
            raise ValueError(
                f"Unsupported hostname prefix for domain inference: {hostname}"
            )

    return dpi, vm_info, product_name