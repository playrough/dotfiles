#!/bin/sh
set -e

MARKET=${MARKET:-en-US}
OUTPUT_DIR=${OUTPUT_DIR:-$HOME/Downloads/wallpapers/bing}
MIN_SIZE=100000  # 100KB minimum to consider valid

mkdir -p "$OUTPUT_DIR"

API_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt=$MARKET"

echo "Fetching Bing metadata..."
JSON=$(wget -qO- "$API_URL")

# More robust extraction using the url field before urlbase
IMG_PATH=$(echo "$JSON" | sed 's/.*"url":"\([^"]*\)".*/\1/' | head -n1)

BASE_URL="https://www.bing.com${IMG_PATH}"

echo "Base URL: $BASE_URL"

# Extract original filename from id= parameter
ORIGINAL_FILENAME=$(echo "$BASE_URL" | sed -n 's/.*[?&]id=\([^&]*\).*/\1/p')

if [ -z "$ORIGINAL_FILENAME" ]; then
    echo "Failed to extract filename from URL: $BASE_URL"
    exit 1
fi

echo "Original filename: $ORIGINAL_FILENAME"

# Build UHD filename
UHD_FILENAME=$(echo "$ORIGINAL_FILENAME" | sed 's/_[0-9]*x[0-9]*\.jpg$/_UHD.jpg/')
UHD_URL="https://www.bing.com/th?id=${UHD_FILENAME}"
ORIGINAL_URL="$BASE_URL"

echo "UHD filename: $UHD_FILENAME"

# Check if already downloaded (check both possible filenames)
if [ -f "$OUTPUT_DIR/$UHD_FILENAME" ]; then
    echo "Already downloaded (UHD): $UHD_FILENAME"
    ln -sf "$OUTPUT_DIR/$UHD_FILENAME" "$OUTPUT_DIR/latest.jpg"
    exit 0
fi

if [ -f "$OUTPUT_DIR/$ORIGINAL_FILENAME" ]; then
    echo "Already downloaded: $ORIGINAL_FILENAME"
    ln -sf "$OUTPUT_DIR/$ORIGINAL_FILENAME" "$OUTPUT_DIR/latest.jpg"
    exit 0
fi

# Function to test if a URL returns a valid large image
test_valid_image() {
    URL="$1"
    TMPFILE=$(mktemp)

    wget -q -L "$URL" -O "$TMPFILE" 2>/dev/null || { rm -f "$TMPFILE"; return 1; }

    SIZE=$(wc -c < "$TMPFILE")
    rm -f "$TMPFILE"

    if [ "$SIZE" -gt "$MIN_SIZE" ]; then
        return 0
    else
        return 1
    fi
}

echo "Testing UHD availability..."
if test_valid_image "$UHD_URL"; then
    echo "UHD available. Downloading..."
    FINAL_URL="$UHD_URL"
    FINAL_FILENAME="$UHD_FILENAME"
else
    echo "UHD not available. Falling back to 1080p."
    FINAL_URL="$ORIGINAL_URL"
    FINAL_FILENAME="$ORIGINAL_FILENAME"
fi

DEST="$OUTPUT_DIR/$FINAL_FILENAME"

echo "Downloading from: $FINAL_URL"
wget -q -L "$FINAL_URL" -O "$DEST" || {
    echo "Download failed."
    rm -f "$DEST"
    exit 1
}

# Verify downloaded file size
SIZE=$(wc -c < "$DEST")
if [ "$SIZE" -lt "$MIN_SIZE" ]; then
    echo "Downloaded file too small (${SIZE} bytes), likely an error page."
    rm -f "$DEST"
    exit 1
fi

echo "Download complete: $DEST (${SIZE} bytes)"

ln -sf "$DEST" "$OUTPUT_DIR/latest.jpg"
