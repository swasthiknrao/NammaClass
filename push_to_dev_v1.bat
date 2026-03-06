@echo off
REM Push NammaClass to dev-v1 with author nraoswasthik2004@gmail.com
cd /d "c:\Users\HP\Desktop\rakshith anna\ERP\nammaclass"

REM Set author for this repo (contributor email)
git config user.email "nraoswasthik2004@gmail.com"
git config user.name "Swasthik N Rao"

REM Ensure we're on dev-v1
git checkout dev-v1 2>nul || git checkout -b dev-v1

REM Stage all changes
git add -A

REM Commit only if there are staged changes
git diff --cached --quiet
if errorlevel 1 git commit -m "NammaClass full UI: design system, 50+ screens, clean analyze"

REM Push to origin dev-v1
git push -u origin dev-v1

echo Done. Check GitHub: https://github.com/swasthiknrao/NammaClass branch dev-v1
pause
