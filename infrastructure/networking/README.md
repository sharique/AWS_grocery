# Networking Module

This module provisions the core network layer for the GroceryMate application on AWS. All other modules (compute, database) depend on the resources created here.

## Resources

1. **VPC** - A dedicated Virtual Private Cloud with CIDR `10.0.0.0/16` that isolates all application resources.

2. **Public Subnets** - Two subnets for EC2 instances, one per availability zone:
    - `public_a` — `10.0.1.0/24` in `eu-central-1a`
    - `public_b` — `10.0.2.0/24` in `eu-central-1b`

3. **Private Subnets** - Two isolated subnets for RDS, unreachable from the internet:
    - `private_a` — `10.0.3.0/24` in `eu-central-1a`
    - `private_b` — `10.0.4.0/24` in `eu-central-1b`

4. **Internet Gateway** - Attached to the VPC, allows EC2 instances in public subnets to reach the internet.

5. **Route Tables** - Two route tables:
    - Public route table routes `0.0.0.0/0` traffic to the Internet Gateway, associated with both public subnets.
    - Private route table has no outbound internet route, keeping the database subnets isolated.

6. **DB Subnet Group** - Spans `private_a` and `private_b`, required by RDS for multi-AZ placement.

## Outputs

| Output | Description |
|---|---|
| `vpc_id` | ID of the created VPC |
| `subnet_public_a_id` | ID of the primary public subnet (used by EC2) |
| `db_subnet_group_name` | Name of the RDS subnet group |
