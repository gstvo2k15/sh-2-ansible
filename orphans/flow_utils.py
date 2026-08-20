"""Utility functions to extract flow data from Capsule or Vanish APIs."""


def extract_inputs_from_items(items, hostname):
    """Extract inputs_list[0] from each item if present."""
    results = []

    for index, item in enumerate(items):
        context = item.get("context", {})
        inputs = context.get("inputs", {})
        inputs_list = inputs.get("inputs_list", [])

        if inputs_list:
            results.append(inputs_list[0])
        else:
            print(
                f"{hostname} => missing context.inputs.inputs_list "
                f"at index {index}"
            )

    return results