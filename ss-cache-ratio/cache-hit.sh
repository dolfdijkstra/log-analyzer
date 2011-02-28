echo "New request for page: " `grep 'New request for page' "$1" |wc -l`
echo "New request for blob: " `grep 'New request for blob' "$1" | wc -l`
echo "Attempting to return bytes for page: " `grep 'Attempting to return bytes for: page:' "$1" | wc -l`
echo "Attempting to return bytes for blob: " `grep 'Attempting to return bytes for: blob:' "$1" | wc -l`
echo "Fetched from cache: " `grep 'Fetched from cache' "$1" | wc -l`
echo "Requesting from Content Server: " `grep 'Requesting from Content Server' "$1" | wc -l`
echo "Caching: " `grep 'Caching ' "$1" | wc -l`
echo "Released from cache: " `grep 'Released from cache' "$1" | wc -l`
