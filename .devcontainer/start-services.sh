#!/bin/bash
set -e

echo "Starting Odoo development services..."

# Check if PostgreSQL is available
if command -v pg_isready >/dev/null 2>&1; then
    echo "Checking PostgreSQL connection..."
    pg_isready -h postgres -p 5432 -U odoo || echo "PostgreSQL not ready yet"
fi

# Set development environment variables
export ODOO_DEV=true
export PYTHONPATH="/workspace/addons:${PYTHONPATH}"

# Start any additional development services
echo "Services initialization complete!"
