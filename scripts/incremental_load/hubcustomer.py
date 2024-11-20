import mysql.connector
from mysql.connector import Error
import logging
import configparser
from typing import Optional, Dict, List, Tuple

# Configurar logging
logging.basicConfig(filename='data_load.log', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def fetch_source_data(cursor, last_load_date: str) -> List[Tuple]:
    """Fetch new or modified records from the source table."""
    cursor.execute("""
        SELECT
            hashkeycustomer,
            dt_load_date,
            recordsource
        FROM
            source_hubcustomer
        WHERE
            dt_load_date > %s;
    """, (last_load_date,))
    return cursor.fetchall()

def insert_staging_data(cursor, data: Tuple) -> None:
    """Insert a single record into the staging table."""
    cursor.execute("""
        INSERT INTO staging_hubcustomer (
            hashkeycustomer,
            dt_load_date,
            recordsource
        )
        VALUES (%s, %s, %s);
    """, data)

def load_data() -> None:
    # Leer configuración de la base de datos desde un archivo
    config = configparser.ConfigParser()
    try:
        config.read('db_config.ini')
        db_config: Dict[str, str] = config['mysql']
    except KeyError as e:
        logging.error(f"Error de configuración: {e}")
        return

    connection: Optional[mysql.connector.connection_cext.CMySQLConnection] = None

    try:
        # Conectar a la base de datos
        connection = mysql.connector.connect(
            host=db_config.get('host'),
            database=db_config.get('database'),
            user=db_config.get('user'),
            password=db_config.get('password')
        )
    except mysql.connector.Error as e:
        logging.error(f"Error de conexión a la base de datos: {e}")
        return

    try:
        if connection.is_connected():
            cursor = connection.cursor()

            # Comienza una transacción
            logging.info("Iniciando transacción.")
            cursor.execute("START TRANSACTION;")

            # Paso 2: Crear la Tabla de Control
            cursor.execute("""
                INSERT INTO load_control (
                    table_name,
                    last_load_date
                )
                VALUES ('hubcustomer', '2023-01-01 00:00:00')
                ON DUPLICATE KEY UPDATE
                    last_load_date = VALUES(last_load_date);
            """)

            # Obtener la última fecha de carga
            cursor.execute("""
                SELECT
                    last_load_date
                FROM
                    load_control
                WHERE
                    table_name = 'hubcustomer';
            """)
            last_load_date: Optional[str] = cursor.fetchone()[0]

            # Paso 3: Extraer Nuevos o Modificados Registros
            source_data = fetch_source_data(cursor, last_load_date)

            # Insertar cada registro individualmente en la tabla de staging
            for data in source_data:
                insert_staging_data(cursor, data)

            # Paso 4: Implementar Carga Incremental
            cursor.execute("""
                INSERT INTO hubcustomer (
                    hashkeycustomer,
                    dt_load_date,
                    recordsource
                )
                SELECT
                    s.hashkeycustomer,
                    s.dt_load_date,
                    s.recordsource
                FROM
                    staging_hubcustomer s
                LEFT JOIN
                    hubcustomer h ON s.hashkeycustomer = h.hashkeycustomer
                WHERE
                    h.hashkeycustomer IS NULL;
            """)

            # Paso 5: Actualizar la Tabla de Control
            cursor.execute("""
                UPDATE load_control
                SET
                    last_load_date = (
                        SELECT MAX(dt_load_date)
                        FROM staging_hubcustomer
                    )
                WHERE
                    table_name = 'hubcustomer';
            """)

            # Confirmar la transacción
            connection.commit()
            logging.info("Carga de datos completada y transacción confirmada.")

            # Paso 6: Limpiar la Tabla de Staging
            cursor.execute("TRUNCATE TABLE staging_hubcustomer;")
            logging.info("Tabla de staging limpiada.")

    except mysql.connector.Error as sql_error:
        logging.error(f"Error durante la ejecución de SQL: {sql_error}")
        if connection and connection.is_connected():
            connection.rollback()
            logging.info("Transacción revertida debido a un error.")

    except Exception as general_error:
        logging.error(f"Error inesperado: {general_error}")
        if connection and connection.is_connected():
            connection.rollback()
            logging.info("Transacción revertida debido a un error inesperado.")

    finally:
        if connection and connection.is_connected():
            cursor.close()
            connection.close()
            logging.info("Conexión a la base de datos cerrada.")

if __name__ == "__main__":
    load_data()
