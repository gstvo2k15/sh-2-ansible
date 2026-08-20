"""Helper functions for hostname-based inference."""

import re


def _infer_country(hostname):
    """Infer country code base on hostname prefix."""
    if re.search(r'^(eur|mac)', hostname, re.IGNORECASE):
        return 'FR'
    if re.search(r'^sin', hostname, re.IGNORECASE):
        return 'SG'
    if re.search(r'^nar', hostname, re.IGNORECASE):
        return 'US'
    return 'FR'


def _infer_platform(product_name):
    """Infer platform code base on product name."""
    patterns = {
        'dpi_upgraded_tomcat': 'dpi_upgraded_tomcat',
        'dpi_upgraded_apache': 'dpi_upgraded_apache',
        'iis': 'iis',
        'tomcat': 'tomcat',
        'apache': 'apache',
        'weblogic': 'weblogic',
        'wasnd': 'wasnd',
        'unix': 'dpi_upgraded_tomcat',
        'wasbase_admin_vmware': 'wasbase_admin_vmware',
        'wasbase_nodes_vmware': 'wasbase_nodes_vmware'
    }

    for pattern, result in patterns.items():
        if re.search(pattern, product_name, re.IGNORECASE):
            return result

    return ''