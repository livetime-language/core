# Database Schema
Model classes define the database schema and the Pocketbase access rules.
Run "livetime schema update <target>" to update database. Use target "Editor" for local development.
After merging a branch, run schema update in the target directory if needed.

# Ask to write data migration if needed
Don't write migrations without asking. When you are done and a change requires a migration, ask the user if you should write and run a one-time script to update the production database.
