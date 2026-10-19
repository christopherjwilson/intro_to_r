#!/usr/bin/env bash
set -e

# Ensure at least one file was passed
if [ "$#" -eq 0 ]; then
  echo "Usage: ./render_pdf.sh slides/Lecture1.qmd [slides/Lecture2.qmd ...]"
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PORT=8080

# 1. Start background static server from the docs directory
echo "Starting local static server..."
npx serve "$PROJECT_ROOT/docs" -l $PORT > /dev/null 2>&1 &
SERVER_PID=$!

# Ensure the background server is terminated even if the script errors or is interrupted
cleanup() {
  echo "Stopping server (PID: $SERVER_PID)..."
  kill "$SERVER_PID" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

# Allow server a brief moment to bind to the port
sleep 1.5

# 2. Process each passed .qmd file
for input_path in "$@"; do
  # Resolve to relative path from project root if full path was provided
  rel_path="${input_path#$PROJECT_ROOT/}"
  filename=$(basename -- "$rel_path")
  base_name="${filename%.*}"
  dir_name=$(dirname "$rel_path")

  echo "----------------------------------------------------"
  echo "Rendering: $rel_path"
  quarto render "$PROJECT_ROOT/$rel_path"

  # Path to generated files inside docs/
  html_subpath="$dir_name/$base_name.html"
  output_pdf="$PROJECT_ROOT/docs/$dir_name/$base_name.pdf"

  echo "Exporting PDF: $output_pdf"
  npx decktape reveal --size 1920x1080 "http://localhost:$PORT/$html_subpath" "$output_pdf"
  echo "Done: $base_name.pdf"
done

echo "----------------------------------------------------"
echo "All files processed successfully."
