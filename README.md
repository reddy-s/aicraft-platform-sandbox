# AICraft Platform Sandbox

A development sandbox environment for the AICraft Platform — a pharmaceutical batch manufacturing data processing system. This platform enables real-time batch data collection, event processing, and analytics for pharmaceutical production workflows.

## Overview

The AICraft Platform processes batch manufacturing data from DCS (Distributed Control System) sources, routes events through an MQTT message broker, and persists processed data for analytics and reporting.

### Architecture

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   MSSQL Server  │────▶│  AICraft Beat   │────▶│   Mosquitto     │
│  (Batch Source) │     │  (Data Reader)  │     │  (MQTT Broker)  │
└─────────────────┘     └─────────────────┘     └────────┬────────┘
                                                         │
                        ┌────────────────────────────────┼────────────────────────────────┐
                        │                                │                                │
                        ▼                                ▼                                ▼
              ┌─────────────────┐              ┌─────────────────┐              ┌─────────────────┐
              │  Event Processor│              │  Store Drainer  │              │   API Server    │
              │                 │              │                 │              │  (Mock REST)    │
              └─────────────────┘              └────────┬────────┘              └─────────────────┘
                                                        │
                                                        ▼
                                               ┌─────────────────┐
                                               │   PostgreSQL    │
                                               │ (Analytics DB)  │
                                               └─────────────────┘
```

## Services

| Service | Image | Port | Description |
|---------|-------|------|-------------|
| **api-server** | `clue/json-server` | 3000 | Mock REST API serving pharmaceutical stock dispatch data |
| **mosquitto** | `eclipse-mosquitto:2.0.22` | 1883 | MQTT message broker for event routing |
| **mssql** | `mcr.microsoft.com/mssql/server:2022-latest` | 1433 | SQL Server database for batch manufacturing data |
| **postgres** | `postgres:18.1-alpine` | 5432 | PostgreSQL database for processed analytics data |
| **aicraft-beat** | `ghcr.io/reddy-s/aicraft-beat:v0.0.3` | - | Reads batch data from MSSQL and publishes to MQTT |
| **aicraft-event-processor** | `ghcr.io/reddy-s/aicraft-event-processor:v0.0.1` | - | Processes events from MQTT |
| **aicraft-store-drainer** | `ghcr.io/reddy-s/aicraft-store-drainer:v0.0.2` | - | Drains processed events to PostgreSQL |

## Prerequisites

- Docker & Docker Compose
- Environment variables configured (see [Configuration](#configuration))

## Configuration

Create a `.env` file in the project root with the following variables:

```env
MSSQL_DB_PASSWORD=YourStrongPassword123!
POSTGRES_PASSWORD=YourPostgresPassword123!
```

> **Note:** MSSQL requires a strong password with uppercase, lowercase, numbers, and special characters.

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd aicraft-platform-sandbox
   ```

2. **Create the environment file:**
   ```bash
   cp .env.example .env
   # Edit .env with your passwords
   ```

3. **Start all services:**
   ```bash
   docker-compose up -d
   ```

4. **Check service status:**
   ```bash
   docker-compose ps
   ```

5. **View logs:**
   ```bash
   docker-compose logs -f
   ```

## Data Model

### BatchInsights Database (MSSQL)

The source database contains pharmaceutical batch manufacturing data:

#### AppStatus Table
Tracks batch execution status with fields including:
- `BatchId`, `BatchStatus`, `BatchStartTime`, `BatchEndTime`
- `RecipeName`, `RecipeVersion`, `ProductName`
- `UnitName`, `UnitStatus`, `UnitStartTime`, `UnitEndTime`
- Approval and security metadata

#### AppItemValue Table
Stores batch item values with fields including:
- `BatchId`, `RecipeName`, `UnitName`
- `ItemName`, `ItemValue`, `CommonBlockStatus`
- `PlantNo`, `SiteName`, `ProductName`

### Mock API Data

The REST API serves pharmaceutical stock dispatch data with activities:
- `raw_stock_in` - Raw material received
- `raw_stock_consumption` - Raw material consumed in production
- `raw_stock_available` - Available raw material inventory
- `filling` - Product filling at designated stations (FS-01 through FS-05)
- `finished_good_stocked` - Finished products added to inventory
- `finished_good_dispatched` - Finished products shipped

**Tracked pharmaceutical products include:**
- Paracetamol 500mg Tablets
- Amoxicillin 250mg Capsules
- Metformin 500mg Tablets
- Omeprazole 20mg Capsules
- And many more...

## API Endpoints

The mock API server exposes:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `GET /stock_dispatch` | GET | List all stock dispatch events |
| `GET /stock_dispatch/:id` | GET | Get specific dispatch event |
| `POST /stock_dispatch` | POST | Create new dispatch event |
| `PUT /stock_dispatch/:id` | PUT | Update dispatch event |
| `DELETE /stock_dispatch/:id` | DELETE | Delete dispatch event |

**Example:**
```bash
# Get all stock dispatch data
curl http://localhost:3000/stock_dispatch

# Filter by recipe
curl http://localhost:3000/stock_dispatch?recipe_name=Paracetamol%20500mg%20Tablets
```

## MQTT Topics

The Mosquitto broker handles event routing. Connect using:

```bash
# Subscribe to all topics
mosquitto_sub -h localhost -p 1883 -t '#' -v

# Publish a test message
mosquitto_pub -h localhost -p 1883 -t 'test/topic' -m 'Hello World'
```

## Database Connections

### MSSQL Server
```
Host: localhost
Port: 1433
Database: BatchInsights
Username: sa
Password: <MSSQL_DB_PASSWORD>
```

### PostgreSQL
```
Host: localhost
Port: 5432
Database: aicraftbatch
Username: postgres
Password: <POSTGRES_PASSWORD>
```

## Development

### Directory Structure

```
.
├── docker-compose.yaml          # Service definitions
├── README.md                    # This file
├── .gitignore                   # Git ignore rules
└── .data/
    ├── beat/                    # AICraft Beat state data
    ├── config/
    │   └── mosquitto/
    │       └── mosquitto.conf   # MQTT broker configuration
    ├── mock/
    │   ├── api/
    │   │   └── db.json          # Mock API data
    │   ├── data/
    │   │   ├── DCSBatchAppItemValues-1.csv
    │   │   └── DCSBatchAppStatus-1.csv
    │   └── mssql/
    │       ├── entrypoint.sh    # Database initialization script
    │       ├── init-db.sql      # Schema creation
    │       └── import-data.sql  # Data import script
    ├── mosquitto/               # MQTT broker data (gitignored)
    ├── mssql/                   # MSSQL data files (gitignored)
    └── postgres/                # PostgreSQL data files (gitignored)
```

### Rebuilding Services

```bash
# Stop and remove all containers
docker-compose down

# Remove volumes for fresh start
docker-compose down -v

# Rebuild and start
docker-compose up -d --build
```

### Viewing Container Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f aicraft-beat
docker-compose logs -f mssql
```

## Troubleshooting

### MSSQL Not Starting
- Ensure the password meets complexity requirements
- Check available disk space for data files
- Wait 30-60 seconds for initial startup

### Database Not Initialized
- Check MSSQL logs: `docker-compose logs mssql`
- Verify CSV files exist in `.data/mock/data/`
- Ensure entrypoint script has execute permissions

### Services Not Connecting
- Verify all dependent services are healthy
- Check network connectivity between containers
- Ensure environment variables are properly set

## License

[Add your license here]

## References

- [Eclipse Mosquitto](https://mosquitto.org/)
- [Microsoft SQL Server Docker](https://hub.docker.com/_/microsoft-mssql-server)
- [PostgreSQL Docker](https://hub.docker.com/_/postgres)
- [JSON Server](https://github.com/typicode/json-server)
