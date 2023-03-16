@echo off
echo "Rebuilding components from scratch.."
docker compose build --no-cache
echo "Rebuilding complete. You can close this window now."
pause