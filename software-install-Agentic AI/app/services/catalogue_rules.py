def is_source_allowed(catalogue_source: str, request_source: str) -> bool:
    """
    Return True if the request source is allowed for the catalogue item.
    Supported catalogue_source values:
      - ADMIN_PORTAL
      - SERVICENOW
      - BOTH
    """
    if catalogue_source == "BOTH":
        return True

    return catalogue_source == request_source