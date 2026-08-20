"""Vanish module for managing orphan VM cleanup using Capsule and Vanish API."""

import os
import json
import re

from authlib.integrations.requests_client import OAuth2Session

from clean_orphans.config import DRY_RUN, ALLOWED_ENV, ALLOWED_REGION, USERNAME, PASSWORD
from clean_orphans.capsule import get_capsule_info
from clean_orphans.flow_utils import extract_inputs_from_items
from clean_orphans.auth import create_session

from clean_orphans.payloads import (
    build_vmware_payload, build_openstack_payload, build_ibm_payload
)

from clean_orphans.filters import (
    _ensure_valid_fqdn
)

from clean_orphans.validators import check_env_and_region
from clean_orphans.inference import _infer_country, _infer_platform

class DeleteOrphan:
    """Manager for orphan VMs: fetch, validate and delete using Capsule and Vanish APIs."""

    orphan_vm_list_endpoint = (
        "https://robotic-capsule.cib.echonet/vms/orphans?page_size=1000&page_num={}"
    )

    flow_create_endpoint_dict = {
        "vmware": (
            "https://vanish-api-prd.xmp.net.intra/vanish/api/v2/jobs/"
            "?full_text_search={}&page=1&size=10"
        ),
        "openstack": (
            "https://vanish-api-prd.xmp.prd.net.intra/vanish/api/v2/jobs/"
            "?full_text_search={}&page=1&size=10"
        )
    }

    openid_token_url = (
        "https://robotic-auth.cib.echonet/auth/realms/production/"
        "protocol/openid-connect/token"
    )

    orphan_vm_delete_endpoint = (
        "https://robotic-vanish.cib.echonet/vanish/api/v1/jobs/"
    )

    vmware_flow_version = "4.2"
    vmware_flow_version_no_domain = "notag"
    ibm_flow_version = "4.3"
    openstack_flow_version = "notag"
    default_dns_domain = "xmp.net.intra"
    middleware_product_list = ('dpi_upgraded_tomcat',)

    def _infer_country(self, hostname):
        return _infer_country(hostname)

    def _infer_platform(self, product_name):
        return _infer_platform(product_name)

    def __init__(self):
        """Initialize the DeleteOrphan manager with Capsule and Vanish credentials."""
        self.capsule_api_key = os.environ.get("CAPSULE_API_KEY")
        if not self.capsule_api_key:
            raise RuntimeError("Missing CAPSULE_API_KEY environment variable")
        self.session = create_session(USERNAME, PASSWORD)
        self.all_vm_list = []
        self.vm_to_delete_list = []
        self.capsule_url = "https://api-platform.cib.echonet/IV2-capsule/referential?hostname={}"

    def get_all_vm(self):
        """Retrieve list of orphan VMs filtered by middleware products."""
        for page in range(1, 11):
            vm_list_url_page = self.orphan_vm_list_endpoint.format(page)
            print("url:", vm_list_url_page)
            vm_list_response_page = self.session.get(vm_list_url_page)
            vm_list_response_json_page = json.loads(vm_list_response_page.text)

            if vm_list_response_json_page:
                if vm_list_response_page.status_code in (200, 201):
                    self.all_vm_list.extend(vm_list_response_json_page)
                    for entry in vm_list_response_json_page:
                        if entry["product_name"] in self.middleware_product_list:
                            vm_fqdn = self._ensure_valid_fqdn(
                                entry.get("hostname"),
                                entry.get("fqdn")
                            )

                            self.vm_to_delete_list.append({
                                "hostname": entry.get("hostname"),
                                "fqdn": vm_fqdn,
                                "track_id": entry.get("sub_id"),
                                "job_id": entry.get("vanish_job_id"),
                                "provider": entry.get("provider"),
                                "product_name": entry.get("product_name"),
                            })
        else:
            print("List orphan error http:", vm_list_response_page.status_code)
    else:
        break
return self.vm_to_delete_list

def _ensure_valid_fqdn(self, hostname, fqdn_value):
    """Ensure FQDN is valid, generate if missing or incomplete."""
    if not fqdn_value or "." not in fqdn_value:
        return ".".join([hostname, self.default_dns_domain])
    return fqdn_value

def _infer_country(self, hostname):
    return _infer_country(hostname)

def _infer_platform(self, product_name):
    return _infer_platform(product_name)

def get_capsule_info_wrapper(self, hostname):
    """Get Capsule info and format it."""
    params = {
        'session': self.session,
        'capsule_url': self.capsule_url,
        'api_key': self.capsule_api_key,
        'hostname': hostname,
        'infer_country_fn': _infer_country,
        'infer_platform_fn': _infer_platform
    }
    result = get_capsule_info(params)
    if not result:
        return None
    dpi, vm_info, product_name = result
    print(f"Product info for {hostname}: {product_name}")

    dpi["fqdn"] = self._ensure_valid_fqdn(
        dpi["hostname"],
        dpi.get("fqdn")
    )

    if vm_info['provider'] == 'vmware':
        return {
            'provider': vm_info['provider'],
            'hostname': dpi['hostname'],
            'fqdn': dpi['fqdn'],
            'domain': dpi.get('domain', ''),
            'region': dpi['region'],
            'location': dpi['location'],
            'zone': dpi['zone'],
                'site': dpi['site'],
                'os': dpi['os'],
                'env': dpi['env'],
                'platform_object': dpi['platform_object'].lower()
            }

        if vm_info['provider'] == 'openstack':
            return {
                'provider': vm_info['provider'],
                'hostname': dpi['hostname'],
                'ecosystem': dpi['ecosystem'],
                'region': dpi['region'],
                'country': dpi.get('country', "FR"),
                'location': dpi['location'],
                'zone': dpi['zone'],
                'env': dpi['env'],
                'os': dpi['os'],
                'platform_object': dpi['platform_object'].lower()
            }

        return {}

    def get_flow_create_info(self, data):
        """Retrieve VM creation flow info to validate deletion criteria."""
        result = []
        if not data:
            print("=== no data")
            return result

        provider = data["provider"]
        hostname = data["hostname"]
        fqdn = data["fqdn"]

        print("========= machine processing:", hostname)
        print("product name:", data["product_name"])

        flow_create_url = self.flow_create_endpoint_dict[provider].format(hostname)
        headers = {
            "Content-Type": "application/json",
            "Accept": "application/json",
            "x-apikey": self.capsule_api_key
        }

        resp = self.session.get(flow_create_url, headers=headers)
        print(f"flow create request status: {response.status_code}")

        if resp.status_code == 200:
            payload = json.loads(resp.text)
            items = payload.get("items", [])
            if items:
                inputs_list = self.extract_inputs_from_items(items, hostname)
                if inputs_list:
                    if provider == "vmware":
                        result = self._build_vmware_info(inputs_list, provider, hostname, fqdn)
                    elif provider == "openstack":
                        result = self._build_openstack_info(inputs_list, provider, hostname)
                    else:
                        print("Not implemented")
                else:
                    print(f"{hostname} => no valid input_list")
            else:
                print(f"{hostname} => no flow_create info")
        else:
            print(f"query failed full_text_search: {resp.status_code}")

    def _build_vmware_info(self, data, provider, hostname, fqdn):
        """Build VMWare-specific info for deletion payload."""
        required = ['region', 'location', 'os', 'env', 'platform_object']
        result = []
        for entry in data:
            if all(k in entry for k in required):
                result.append({
                    "provider": provider,
                    "hostname": hostname,
                    "fqdn": fqdn,
                    "region": entry["region"],
                    "location": entry["location"],
                    "zone": entry.get("zone", "PRD"),
                    "site": entry["site"],
                    "os": entry["os"],
                    "platform_object": entry["platform_object"].lower()
                })
            else:
                print(f"{hostname} => missing parameter in input_list (vmware)")
        return result

    def _build_openstack_info(self, data, provider, hostname):
        """Build OpenStack-specific info for deletion payload."""
        required = ['ecosystem', 'region', 'country', 'location', 'os', 'env', 'platform_object']
        result = []
        for entry in data:
            if all(k in entry for k in required):
                result.append({
                    "provider": provider,
                    "hostname": hostname,
                    "ecosystem": entry["ecosystem"],
                    "region": entry["region"],
                    "country": entry["country"],
                    "location": entry["location"],
                    "zone": entry.get("zone", "PRD"),
                    "env": entry["env"],
                    "os": entry["os"],
                    "platform_object": entry["platform_object"].lower()
                })
            else:
                print(f"{hostname} => missing parameter in input_list (openstack)")
        return result

    def delete_vm(self, dpi_info, hostname):
       """Trigger deletion flow for a given VM using Vanish API."""
       if not dpi_info:
           print("No DPI info for machine", hostname)
           return None

        print(f"DEBUG: Environment raw value: {dpi_info['env']}")
        print(f"DEBUG: Region raw value: {dpi_info['region']}")

        if not check_env_and_region(dpi_info):
            return None

        if dpi_info["provider"] == "vmware":
            payload = build_vmware_payload(
                dpi_info,
                version=self.vmware_flow_version,
                default_version=self.vmware_flow_version_no_domain
            )
        elif dpi_info["provider"] == "openstack":
            payload = build_openstack_payload(
                dpi_info,
                version=self.openstack_flow_version
            )

        elif dpi_info["provider"] == "ibm":
            payload = build_ibm_payload(
                dpi_info,
                version=self.ibm_flow_version
            )

        else:
            print("Not implemented =>", dpi_info["provider"])
            return None

        if DRY_RUN:
            print(f"[DRY_RUN] Would delete: {hostname} ({dpi_info['provider']})")
            print(f"[DRY_RUN] Payload: {json.dumps(payload, indent=2)}")
            return None

        print(f"[REAL_RUN] Payload to be sent:")
        print(json.dumps(payload, indent=2))

        self.session.fetch_token(
            self.openid_token_url,
            grant_type="password",
            username=USERNAME,
            password=PASSWORD
        )
        resp = self.session.post(
            self.orphan_vm_delete_endpoint,
            json=payload,
            params={"bulk": True}
        )
        print(f"[REAL_RUN] Response status code: {resp.status_code}")
        try:
            print(f"[REAL_RUN] Response text of job_id: {resp.json()['job_id']}")
        except (json.JSONDecodeError, KeyError):
            print(f"[REAL_RUN] Response text of job_id: {resp.text}")
        return resp


    def delete_from_file(self, data_extract):
        """Delete VMs based on JSON file input (real or dry-run)."""
        with open(data_extract, encoding="utf-8") as fh:
            json_data = json.load(fh)
            for orphan_data in json_data:
                result = self.delete_vm(orphan_data, orphan_data["hostname"])
                if result:
                    print("job_id:", result.text)

    def delete_from_token_json(self, json_file_path):
        """Delete VM using a Bearer-token-based JSON input."""
        with open(json_file_path, encoding="utf-8") as fh:
            data = json.load(fh)

        provider = data.get("provider", "vmware").lower()
        hostname = data["hostname"]
        fqdn = data["fqdn"]
        env = data["environment"]
        os_field = data["os"]
        if isinstance(os_field, dict):
            os_dict = os_field
        else:
            os_dict = {"name": str(os_field)}

        raw_platform = data.get("platform_object", "").lower()
        if raw_platform.startswith("dpi_upgraded_"):
            platform_object = raw_platform.replace("dpi_upgraded_", "")
        else:
            platform_object = raw_platform

        if provider == "openstack":
            if "ecosystem" not in data:
                raise KeyError("OpenStack provider requires the 'ecosystem' key.")
            dpi = {
                "provider": "openstack",
                "hostname": hostname,
                "fqdn": fqdn,
                "ecosystem": data["ecosystem"],
                "region": data.get("region", "EMEA"),
                "country": data.get("country", "FR"),
                "location": data.get("location", "CORE"),
                "zone": "PRD",
                "env": env,
                "os": os_dict,
                "platform_object": platform_object or "unix",
            }

        elif provider == "ibm":
            domain = "warp"
            location = data.get("location", "MZR")
            ibmcloud_id = data.get(
                "ibmcloud_id", "02k7_794af078-5731-4279-ae5f-56081f82c8d5"
            )
            mzr_location = data.get("mzr_location", "BNPP_EU")
            ibm_account = data.get("ibm_account", "EMEA-DMZR-PROD")
            product = data.get("product_name", "").lower()
            if product == "dpi_upgraded_apache":
                platform_object = "apache"
            elif product == "dpi_upgraded_tomcat":
                platform_object = "tomcat"
            dpi = {
                "provider": "ibm",
                "hostname": hostname,
                "fqdn": fqdn,
                "domain": domain,
                "region": data.get("region", "EMEA"),
                "location": location,
                "zone": "PRD",
                "site": "MN",
                "os": os_dict,
                "env": env,
                "platform_object": platform_object.lower(),
                "ibmcloud_id": ibmcloud_id,
                "mzr_location": mzr_location,
                "ibm_account": ibm_account,
                "dpi": [
                    {
                        "domain": domain,
                        "location": location,
                        "ibmcloud_id": ibmcloud_id,
                        "mzr_location": mzr_location,
                        "ibm_account": ibm_account,
                        "platform_object": platform_object.lower(),
                    }
                ],
            }

        else:  # vmware (default)
            domain = "euro"
            location = data.get("location", "CORE")
            product = data.get("product_name", "").lower()
            if product == "dpi_upgraded_apache":
                platform_object = "apache"
            elif product == "dpi_upgraded_tomcat":
                platform_object = "tomcat"

            platform_object = platform_object.lower() if platform_object else "unix"
            dpi = {
                "provider": "vmware",
                "hostname": hostname,
                "fqdn": fqdn,
                "domain": domain,
                "region": data.get("region", "EMEA"),
                "location": location,
                "zone": "PRD",
                "site": "ME",
                "os": os_dict,
                "env": env,
                "platform_object": platform_object,
                "dpi": [
                    {
                        "domain": domain,
                        "location": location,
                        "platform_object": platform_object,
                    }
                ],
            }

        self.delete_vm(dpi, hostname)