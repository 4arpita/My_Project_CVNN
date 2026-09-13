@echo off
setlocal
set "ROOT=%~dp0"

rem Load root .env values and pass them to all child service windows.
if exist "%ROOT%.env" (
  for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ROOT%.env") do (
    if not "%%A"=="" set "%%A=%%B"
  )
)

echo Create the root .env file with the Groq and SMTP values before running.
echo Start MySQL and create vaccination_db first.

start "Email" cmd /k "cd /d ""%ROOT%email-service-dotnet"" && dotnet run --urls http://localhost:8081"
start "Chatbot" cmd /k "cd /d ""%ROOT%chatbot-service-python"" && call setup-and-run-windows.bat"
start "Backend" cmd /k "cd /d ""%ROOT%backend-springboot"" && mvn spring-boot:run"
start "Frontend" cmd /k "cd /d ""%ROOT%frontend-react"" && npm install && npm run dev"

echo Services are starting. Ollama and map API keys are not required.
