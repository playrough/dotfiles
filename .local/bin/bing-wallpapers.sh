#!/bin/sh
set -e

MARKET=${MARKET:-ja-JP}
OUTPUT_DIR=${OUTPUT_DIR:-$HOME/Downloads/wallpapers/bing}
DAYS=${DAYS:-7}
MIN_SIZE=100000

mkdir -p "$OUTPUT_DIR"

API_URL="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=$DAYS&mkt=$MARKET"

echo "Fetching Bing metadata..."
JSON=$(wget -qO- "$API_URL")

if [ -z "$JSON" ]; then
    echo "Failed to fetch Bing metadata."
    exit 1
fi

# Extract image URLs from JSON
IMAGE_URLS=$(printf '%s' "$JSON" | jq -r '.images[]?.url // empty')

if [ -z "$IMAGE_URLS" ]; then
    echo "No images found."
    exit 1
fi

FIRST_IMAGE=1

# Process each image
printf '%s\n' "$IMAGE_URLS" | while IFS= read -r IMG_PATH; do

    BASE_URL="https://www.bing.com${IMG_PATH}"

    ORIGINAL_FILENAME=$(printf '%s\n' "$BASE_URL" |
        sed -n 's/.*[?&]id=\([^&]*\).*/\1/p')

    if [ -z "$ORIGINAL_FILENAME" ]; then
        echo "Skipping invalid image URL."
        continue
    fi

    UHD_FILENAME=$(printf '%s\n' "$ORIGINAL_FILENAME" |
        sed 's/_[0-9]*x[0-9]*\.jpg$/_UHD.jpg/')

    UHD_URL="https://www.bing.com/th?id=${UHD_FILENAME}"

    echo ""
    echo "Processing: $ORIGINAL_FILENAME"

    # Check existing UHD image
    if [ -f "$OUTPUT_DIR/$UHD_FILENAME" ]; then
        echo "Already downloaded (UHD)."
        FINAL_FILENAME="$UHD_FILENAME"

    # Check existing original image
    elif [ -f "$OUTPUT_DIR/$ORIGINAL_FILENAME" ]; then
        echo "Already downloaded (original)."
        FINAL_FILENAME="$ORIGINAL_FILENAME"

    else
        TMPFILE=$(mktemp)

        # Try downloading UHD first
        echo "Trying UHD..."
        if wget -q -L "$UHD_URL" -O "$TMPFILE" 2>/dev/null &&
            [ "$(wc -c < "$TMPFILE")" -gt "$MIN_SIZE" ]; then

            FINAL_FILENAME="$UHD_FILENAME"
            echo "UHD available."

        else
            # Fall back to original image
            echo "UHD unavailable. Falling back to original."

            if ! wget -q -L "$BASE_URL" -O "$TMPFILE" 2>/dev/null ||
                [ "$(wc -c < "$TMPFILE")" -lt "$MIN_SIZE" ]; then

                echo "Download failed or invalid image."
                rm -f "$TMPFILE"
                continue
            fi

            FINAL_FILENAME="$ORIGINAL_FILENAME"
        fi

        DEST="$OUTPUT_DIR/$FINAL_FILENAME"

        mv "$TMPFILE" "$DEST"

        SIZE=$(wc -c < "$DEST")
        echo "Downloaded: $FINAL_FILENAME (${SIZE} bytes)"
    fi

    # latest.jpg always points to today's image
    if [ "$FIRST_IMAGE" -eq 1 ]; then
        ln -sf "$OUTPUT_DIR/$FINAL_FILENAME" "$OUTPUT_DIR/latest.jpg"
        FIRST_IMAGE=0
        echo "Updated latest.jpg"
    fi

done

echo ""
echo "Bing wallpaper download finished."
