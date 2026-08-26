from app.database import get_connection


def _fetch_all(query: str, params=()):
    with get_connection() as connection:
        with connection.cursor() as cursor:
            cursor.execute(query, params)
            columns = [column.name for column in cursor.description]
            return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_collection_types():
    return _fetch_all(
        "SELECT id, name, slug, description FROM collection_types ORDER BY id"
    )


def get_categories():
    return _fetch_all(
        """
        SELECT id, collection_type_id, parent_id, name, slug, description, sort_order
        FROM categories
        ORDER BY collection_type_id, parent_id NULLS FIRST, sort_order, id
        """
    )


def get_collections():
    return _fetch_all(
        """
        SELECT c.id, c.category_id, c.name, c.slug, c.description,
               c.source, c.source_url, c.version,
               COUNT(i.id)::int AS item_count
        FROM collections c
        LEFT JOIN items i ON i.collection_id = c.id
        GROUP BY c.id
        ORDER BY c.id
        """
    )


def get_items(collection_id=None):
    if collection_id is None:
        return _fetch_all(
            """
            SELECT id, collection_id, external_id, name, slug, description,
                   item_number, manufacturer, brand, release_year, release_date, metadata
            FROM items
            ORDER BY collection_id, id
            """
        )

    return _fetch_all(
        """
        SELECT id, collection_id, external_id, name, slug, description,
               item_number, manufacturer, brand, release_year, release_date, metadata
        FROM items
        WHERE collection_id = %s
        ORDER BY id
        """,
        (collection_id,),
    )


def get_item_images(item_id: int):
    return _fetch_all(
        """
        SELECT id, item_id, image_type, width, height, file_size
        FROM item_images
        WHERE item_id = %s
        ORDER BY id
        """,
        (item_id,),
    )


def get_item_image_path(image_id: int):
    rows = _fetch_all(
        "SELECT id, item_id, path FROM item_images WHERE id = %s",
        (image_id,),
    )
    return rows[0] if rows else None


def get_item_files(item_id: int):
    return _fetch_all(
        """
        SELECT id, item_id, file_type, file_size
        FROM item_files
        WHERE item_id = %s
        ORDER BY id
        """,
        (item_id,),
    )


def get_item_file_path(file_id: int):
    rows = _fetch_all(
        "SELECT id, item_id, path FROM item_files WHERE id = %s",
        (file_id,),
    )
    return rows[0] if rows else None
