import os

import psycopg


DB_CONFIG = {
    "host": os.getenv("COLLECTION_DB_HOST", "127.0.0.1"),
    "port": int(os.getenv("COLLECTION_DB_PORT", "5432")),
    "dbname": os.getenv("COLLECTION_DB_NAME", "collection_catalog"),
    "user": os.getenv("COLLECTION_DB_USER", "collection_api"),
    "password": os.getenv("COLLECTION_DB_PASSWORD", ""),
}


def get_connection():
    return psycopg.connect(**DB_CONFIG)
