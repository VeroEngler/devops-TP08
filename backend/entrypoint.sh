#!/bin/bash
echo "Esperando a Postgres..."
until python3 -c "
import psycopg2, os, sys
try:
    conn = psycopg2.connect(
        host=os.getenv('DB_HOST','db'),
        port=os.getenv('DB_PORT','5432'),
        dbname=os.getenv('DB_NAME','notesdb'),
        user=os.getenv('DB_USER','postgres'),
        password=os.getenv('DB_PASSWORD','postgres')
    )
    conn.close()
    sys.exit(0)
except Exception as e:
    sys.stderr.write(str(e) + '\n')
    sys.exit(1)
" 2>> /tmp/postgres_conexion.log; do
    echo "  Postgres no disponible, reintentando en 2s..."
    sleep 2
done
echo "Postgres listo. Iniciando app..."
python3 -c "import app; app.init_db()" 2>> /tmp/postgres_conexion.log || true
exec "$@"
