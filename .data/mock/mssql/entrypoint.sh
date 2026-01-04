#!/bin/bash

# Start SQL Server in the background
/opt/mssql/bin/sqlservr &

# Wait for SQL Server to start
echo "Waiting for SQL Server to start..."
sleep 30

# Check if SQL Server is ready
for i in {1..50}; do
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "SQL Server is ready!"
        break
    fi
    echo "Waiting for SQL Server... attempt $i"
    sleep 2
done

# Run initialization script
echo "Creating database and tables..."
/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i /docker-entrypoint-initdb.d/init-db.sql

# Check if data already exists
ROWS=$(/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -d BatchInsights -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM AppStatus" -h -1 2>/dev/null | tr -d ' ')

if [ "$ROWS" == "0" ] || [ -z "$ROWS" ]; then
    echo "Importing CSV data..."
    /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -i /docker-entrypoint-initdb.d/import-data.sql
else
    echo "Data already exists, skipping import."
fi

echo "Initialization complete!"

# Keep the container running
wait

