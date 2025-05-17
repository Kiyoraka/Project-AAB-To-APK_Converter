@echo off
echo Setting up Git repository for Unity project...

:: Create .gitignore file
echo # List of ignore folder and files > .gitignore
echo /[Tt]emp/ >> .gitignore
echo # List of ignore files >> .gitignore
echo *.exe >> .gitignore
echo *.txt >> .gitignore


:: Initialize git repository
git init

:: Create README.md
echo # PROJECT TITLE > README.md
echo. >> README.md
echo Software Version: [Version] >> README.md
echo. >> README.md
echo ## Description >> README.md
echo This software is used for... >> README.md

:: Remove cached files
git rm -r --cached .

:: Add all files respecting .gitignore
git add .

:: Initial commit
git commit -m "Initial commit"

:: Create main branch
git branch -M main

:: Prompt for GitHub repository URL
set /p repo_url="Enter your GitHub repository URL (e.g., https://github.com/username/repo.git): "

:: Add remote origin
git remote add origin %repo_url%

:: Push to GitHub
git push -u origin main

echo.
echo Repository setup complete!
echo Don't forget to update the README.md
pause
