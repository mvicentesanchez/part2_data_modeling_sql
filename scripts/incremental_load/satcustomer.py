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
            customer_id,
            dt_load_date,
            dt_start_date,
            dt_end_date,
            current_record,
            first_name,
            last_name,
            full_name,
            social_scrty_no,
            cd_natural_legal,
            ds_natural_legal,
            dt_birth,
            address,
            phone_number,
            recordsource
        FROM
            source_satcustomer
        WHERE
            dt_load_date > %s;
    """, (last_load_date,))
    return cursor.fetchall()

def insert_staging_data(cursor, data: Tuple) -> None:
    """Insert a single record into the staging table."""
    cursor.execute("""
        INSERT INTO staging_satcustomer (
            customer_id,
            dt_load_date,
            dt_start_date,
            dt_end_date,
            current_record,
            first_name,
            last_name,
            full_name,
            social_scrty_no,
            cd_natural_legal,
            ds_natural_legal,
            dt_birth,
            address,
            phone_number,
            recordsource
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);
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
                VALUES ('satcustomer', '2023-01-01 00:00:00')
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
                    table_name = 'satcustomer';
            """)
            last_load_date: Optional[str] = cursor.fetchone()[0]

            # Paso 3: Extraer Nuevos o Modificados Registros
            source_data = fetch_source_data(cursor, last_load_date)

            # Insertar cada registro individualmente en la tabla de staging
            for data in source_data:
                insert_staging_data(cursor, data)

            # Paso 4: Implementar Carga Incremental
            cursor.execute("""
                INSERT INTO satcustomer (
                    customer_id,
                    dt_load_date,
                    dt_start_date,
                    dt_end_date,
                    current_record,
                    first_name,
                    last_name,
                    full_name,
                    social_scrty_no,
                    cd_natural_legal,
                    ds_natural_legal,
                    dt_birth,
                    address,
                    phone_number,
                    recordsource
                )
                SELECT
                    s.customer_id,
                    s.dt_load_date,
                    s.dt_start_date,
                    s.dt_end_date,
                    s.current_record,
                    s.first_name,
                    s.last_name,
                    s.full_name,
                    s.social_scrty_no,
                    s.cd_natural_legal,
                    s.ds_natural_legal,
                    s.dt_birth,
                    s.address,
                    s.phone_number,
                    s.recordsource
                FROM
                    staging_satcustomer s
                LEFT JOIN
                    satcustomer c ON s.customer_id = c.customer_id AND s.dt_start_date = c.dt_start_date
                WHERE
                    c.customer_id IS NULL;
            """)

            # Paso 5: Actualizar la Tabla de Control
            cursor.execute("""
                UPDATE load_control
                SET
                    last_load_date = (
                        SELECT MAX(dt_load_date)
                        FROM staging_satcustomer
                    )
                WHERE
                    table_name = 'satcustomer';
            """)

            # Confirmar la transacción
            connection.commit()
            logging.info("Carga de datos completada y transacción confirmada.")

            # Paso 6: Limpiar la Tabla de Staging
            cursor.execute("TRUNCATE TABLE staging_satcustomer;")
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
