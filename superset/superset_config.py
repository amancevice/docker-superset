import json
import os

# ---------------------------------------------------------
# Caravel specific config
# ---------------------------------------------------------
ROW_LIMIT = int(os.getenv("ROW_LIMIT", 5000))
WEBSERVER_THREADS = int(os.getenv("WEBSERVER_THREADS", 8))

CARAVEL_WEBSERVER_PORT = int(os.getenv("CARAVEL_WEBSERVER_PORT", 8088))
# ---------------------------------------------------------

# ---------------------------------------------------------
# Flask App Builder configuration
# ---------------------------------------------------------
# Your App secret key
SECRET_KEY = os.getenv("SECRET_KEY", "\2\1thisismyscretkey\1\2\e\y\y\h")

# The SQLAlchemy connection string.
SQLALCHEMY_DATABASE_URI = os.getenv(
    "SQLALCHEMY_DATABASE_URI", "sqlite:////home/caravel/.caravel/caravel.db")

# Flask-WTF flag for CSRF
CSRF_ENABLED = os.getenv("CSRF_ENABLED", "1") in ("True", "true", "1")

# Set this API key to enable Mapbox visualizations
MAPBOX_API_KEY = os.getenv("MAPBOX_API_KEY", "")

# Whether to run the web server in debug mode or not
DEBUG = os.getenv("DEBUG", "0") in ("True", "true", "1")

try:
    CACHE_CONFIG = json.loads(os.getenv("CACHE_CONFIG", "{}"))
except ValueError:
    CACHE_CONFIG = {}

# Import all the env variables prefixed with "CARAVEL_"
config_keys = [c for c in os.environ if c.startswith("CARAVEL_")]
for key in config_keys:
    globals()[key[8:]] = os.environ[key]

# This file also allows you to define configuration parameters used by
# Flask App Builder, the web framework used by Caravel. Please consult the
# Flask App Builder Documentation for more information on how to configure
# Caravel: http://flask-appbuilder.readthedocs.org/en/latest/config.html
