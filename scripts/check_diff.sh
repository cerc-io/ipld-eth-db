lines=$( git diff --no-index ./db/migration_schema.sql schema.sql | wc -l )
if [ $lines -gt 0 ]; then
    echo "There are differences in schema"
    git diff --no-index ./db/migration_schema.sql schema.sql
    exit 1
fi
echo "Schema is latest"