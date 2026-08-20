"""Authentication module string using OAuth2 with username/password."""
from authlib.integrations.requests_client import OAuth2Session
from clean_orphans.config import TOKEN_URL, VANISH_BEARER_TOKEN


def create_session(username, password):
    """Create and return an authentication OAuth2 session."""
    session = OAuth2Session(client_id="dpi-swagger-ui")
    session.verify = False

    if VANISH_BEARER_TOKEN:
        session.fetch_token = {
            "access_token": VANISH_BEARER_TOKEN,
            "token_type": "Bearer"
        }
    else:
        session.fetch_token(
            TOKEN_URL,
            grant_type="password",
            username=username,
            password=password
        )
    return session
