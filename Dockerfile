# Use the official PostgreSQL image from the Docker Hub
FROM postgres:latest

# Set environment variables for the PostgreSQL database
ENV POSTGRES_DB="elixir_api"
ENV POSTGRES_USER="postgres"
ENV POSTGRES_PASSWORD="postgres"

# Expose the PostgreSQL port
EXPOSE 5432

# Add any additional configuration or initialization scripts if needed
COPY database/create.sql /docker-entrypoint-initdb.d/

# Start the PostgreSQL server
CMD ["postgres"]