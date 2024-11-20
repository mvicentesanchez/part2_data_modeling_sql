import mysql.connector
from datetime import datetime, timedelta

def add_monthly_partition(database_config, table_name):
    try:
        # Conectar a la base de datos
        connection = mysql.connector.connect(**database_config)
        cursor = connection.cursor()

        # Calcular el inicio y fin del próximo mes
        today = datetime.today()
        first_day_next_month = (today.replace(day=1) + timedelta(days=32)).replace(day=1)
        last_day_next_month = (first_day_next_month + timedelta(days=31)).replace(day=1) - timedelta(days=1)

        # Generar el nombre de la partición basado en el año y mes
        partition_name = f"p{first_day_next_month.strftime('%Y%m')}"

        # Log: Inicio del proceso de creación de partición
        cursor.execute("INSERT INTO event_logs (message) VALUES (%s)", (f"Iniciando creación de partición: {partition_name} en {table_name}",))

        # Crear la sentencia SQL para agregar la nueva partición
        sql = (
            f"ALTER TABLE {table_name} "
            f"ADD PARTITION (PARTITION {partition_name} VALUES LESS THAN (TO_DAYS('{last_day_next_month + timedelta(days=1)}')));"
        )

        # Log: Sentencia SQL generada
        cursor.execute("INSERT INTO event_logs (message) VALUES (%s)", (f"Sentencia SQL generada: {sql}",))

        # Ejecutar la sentencia SQL
        cursor.execute(sql)

        # Log: Ejecución de la sentencia SQL completada
        cursor.execute("INSERT INTO event_logs (message) VALUES (%s)", (f"Ejecución de la sentencia SQL completada para partición: {partition_name} en {table_name}",))

        # Confirmar cambios
        connection.commit()

        # Log: Fin del proceso de creación de partición
        cursor.execute("INSERT INTO event_logs (message) VALUES (%s)", (f"Finalizado creación de partición: {partition_name} en {table_name}",))

    except mysql.connector.Error as err:
        print(f"Error: {err}")
    finally:
        if connection.is_connected():
            cursor.close()
            connection.close()

# Configuración de la base de datos
database_config = {
    'user': 'tu_usuario',
    'password': 'tu_contraseña',
    'host': 'localhost',
    'database': 'tu_base_de_datos'
}

# Lista de tablas para las cuales se desea agregar particiones
tables = ['satproduct', 'satcustomer', 'linksalestransaction', 'hubproduct', 'hubcustomer']

# Llamar a la función para agregar una partición a cada tabla de la lista
for table in tables:
    add_monthly_partition(database_config, table)

# Si este script se ejecuta regularmente, considera usar un sistema de cron jobs o similar para automatizar su ejecución mensual.