"""Main entry point to launch orphan VM deletion."""

import sys
from clean_orphans.config import USERNAME, PASSWORD
from clean_orphans.auth import create_session
from clean_orphans.managers import DeleteOrphan
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

if __name__ == "__main__":
    session = create_session(USERNAME, PASSWORD)
    deleter = DeleteOrphan()

    if len(sys.argv) == 3 and sys.argv[1] == "--hostname":
        hostname = sys.argv[2]
        dpi_info = deleter.get_capsule_info_wrapper(hostname)
        if dpi_info:
            deleter.delete_vm(dpi_info, dpi_info["hostname"])
        else:
            print(f"No DPI info found for {hostname}")

    elif len(sys.argv) == 3 and sys.argv[1] == "--file":
        file_path = sys.argv[2]
        deleter.delete_from_file(file_path)

    elif len(sys.argv) == 3 and sys.argv[1] == "--token-json":
        json_file_path = sys.argv[2]
        deleter.delete_from_token_json(json_file_path)

    else:
        print(f"No correct parameters sent for remove orphan VM hostname.")
        print("Usage:")
        print("  python3 -m clean_orphans --hostname <hostname>")
        print("  python3 -m clean_orphans --file <json_file>")
        print("  python3 -m clean_orphans --token-json <json_file>")