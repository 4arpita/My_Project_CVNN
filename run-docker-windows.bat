@echo off
cd /d %~dp0
echo Building and starting Child Vaccination Notifier System...
docker compose up --build
