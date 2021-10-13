file1=$1
file2=$2

lines=$( git diff --no-index "$file1" "$file2" | wc -l )
if [ "$lines" -gt 0 ]; then
    echo "There are differences in schema"
    git diff --no-index "$file1" "$file2"
    exit 1
fi
echo "Schema is latest"