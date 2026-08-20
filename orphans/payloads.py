"""Construct deletion flow payloads for different providers."""

def build_vmware_payload(dpi, version, default_version):
    """Construct VMWare deletion payload for Vanish API."""
    domain = dpi.get('domain', '')
    flow_version = default_version if not domain else version
    return{
        "flow_name": "delete_vmware_iv2_vm_v3",
        "greedy_resolution": "true",
        "flow_version": version,
        "inputs": [
            {
                "hostname": dpi["hostname"],
                "domain": domain,
                "fqdn": dpi["fqdn"],
                "region": dpi["region"],
                "location": dpi["location"],
                "zone": dpi["zone"],
                "site": dpi["site"],
                "os": dpi["os"],
                "env": dpi["env"],
                "owner": "",
                "platform_object": dpi["platform_object"]
            }
        ]
    }

def build_openstack_payload(dpi, version):
    """Construct OpenStack deletion payload for Vanish API."""
    return{
        "flow_name": "delete_openstack_iv2_vm",
        "greedy_resolution": "true",
        "flow_version": version,
        "inputs": [
            {
                "hostname": dpi["hostname"],
                "ecosystem": dpi.get("ecosystem", "default_ecosystem"),
                "region": dpi["region"],
                "country": dpi["country"],
                "location": dpi["location"],
                "zone": dpi["zone"],
                "env": dpi["env"],
                "os": dpi["os"],
                "platform_object": dpi["platform_object"]
            }
        ]
    }

def build_ibm_payload(dpi, version):
    """Construct IBM deletion payload for Vanish API."""
    return {
        "flow_name": "delete_ibmcloud_iv2_vm",
        "greedy_resolution": "true",
        "flow_version": version,
        "inputs": [
            {
                "hostname": dpi["hostname"],
                "domain": "warp",
                "fqdn": dpi["fqdn"],
                "region": dpi["region"],
                "location": "MZR",
                "ibmcloud_id": "02k7_794af078-5731-4279-ae5f-56081f82c8d5",
                "mzr_location": "BNPP_EU",
                "ibm_account": "EMEA-DMZR-PROD",
                "os": dpi["os"],
                "env": dpi["env"],
                "owner": "",
                "platform_object": "apache"
            }
        ]
    }