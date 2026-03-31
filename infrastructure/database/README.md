# Database Module

This module provisions a managed PostgreSQL database on RDS for the GroceryMate application. The database is placed in private subnets with no public access, and only the EC2 web app can connect to it.

## Resources

1. **RDS PostgreSQL Instance** - A `db.t3.micro` instance running PostgreSQL 17.4:
    - Database name: `grocery_db`
    - 20 GB encrypted storage
    - Not publicly accessible — sits entirely within private subnets
    - 7-day automated backup retention
    - Final snapshot skipped on destroy (intended for dev/staging use)

2. **RDS Security Group** - Restricts who can reach the database:
    - Allows inbound PostgreSQL traffic on port `5432` from the EC2 security group only
    - No other source can connect to the database

## Variables

| Variable | Description |
|---|---|
| `vpc_id` | VPC to create the security group in (from networking module) |
| `subnet_group_name` | RDS subnet group name (from networking module) |
| `web_app_sg_id` | EC2 security group ID used as the ingress source (from compute module) |
| `db_username` | Database master username |
| `db_password` | Database master password (sensitive) |

## Outputs

| Output | Description |
|---|---|
| `endpoint` | RDS instance address (used by the application to connect) |
| `port` | Database port (`5432`) |
