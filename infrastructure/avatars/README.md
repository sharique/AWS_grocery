# Avatars Module

This module provisions an S3 bucket used to store user avatar images uploaded through the GroceryMate application. It is independent of the other infrastructure modules.

## Resources

1. **S3 Bucket** (`saf-grocery-store-v3`) - Stores user-uploaded avatar images:
    - Versioning enabled to protect against accidental overwrites or deletions
    - All public access blocked — the application accesses it via IAM, not public URLs
    - Lifecycle rule expires old object versions after 30 days to manage storage costs

## Outputs

| Output | Description |
|---|---|
| `avatar_arn` | ARN of the S3 bucket (used to scope IAM policies) |
