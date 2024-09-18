#!/bin/bash

# Function to generate random keys
generate_key() {
    openssl rand -hex 32
}

# Function to ask yes/no questions
ask_yes_no() {
    while true; do
        read -p "$1 (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes (y) or not (n).";;
        esac
    done
}

# Check if node engine is 18.x

if ! node -v | grep -q "v18"; then
    echo "Please use Node.js version 18.x to continue."
    exit 1
fi

# Request project name
read -p "Enter the project name: " PROJECT_NAME

# Request the port for the application
read -p "Enter the port for the application (default 8055): " PORT
PORT=${PORT:-8055}

# Request information to create admin user
read -p "Enter the admin email (default admin@example.com): " ADMIN_EMAIL
ADMIN_EMAIL=${ADMIN_EMAIL:-admin@example.com}

# Generate admin password
read -p "Enter the admin password (leave empty to generate a random password): " ADMIN_PASSWORD
ADMIN_PASSWORD=${ADMIN_PASSWORD:-$(generate_key)}

# Print credentials
echo "Admin email: $ADMIN_EMAIL"
echo "Admin password: $ADMIN_PASSWORD"

# Generate a random ADMIN_TOKEN
ADMIN_TOKEN=$(generate_key)

# Create project folder and initialize
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"
npm init -y

# Install Directus latest version
npm install directus@latest

# Create .env file
KEY=$(generate_key)
SECRET=$(generate_key)

cat > .env << EOL
# Encryption keys
KEY=$KEY
SECRET=$SECRET

# Database configuration
DB_CLIENT=sqlite3
DB_FILENAME=./directus.db

# Server configuration
PORT=$PORT

# Admin configuration
ADMIN_EMAIL=$ADMIN_EMAIL
ADMIN_PASSWORD=$ADMIN_PASSWORD
ADMIN_TOKEN=$ADMIN_TOKEN
EOL

# Initialize the database
npx directus bootstrap

# Install nodemon for development
npm install --save-dev nodemon@latest concurrently@latest

# Ask about installing extensions
INSTALL_EXTENSION=false

if ask_yes_no "Do you want create a new directus extension?"; then
    INSTALL_EXTENSION=true
fi

# Install extensions if requested
if [ "$INSTALL_EXTENSION" = true ]; then
    mkdir -p extensions
    cd extensions
    npx create-directus-extension@latest
    cd ..
fi

# Create scripts directory
mkdir -p scripts
mkdir -p extensions
# Create dev-extensions.js file
cat > scripts/dev-extensions.js << EOL
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const extensionsDir = path.join(__dirname, '..', 'extensions');

// Get command line arguments
const args = process.argv.slice(2);
const command = args[0] || 'dev'; // Default to 'dev' if no argument is provided

// Get all folders inside the extensions directory
const extensions = fs.readdirSync(extensionsDir, { withFileTypes: true })
  .filter(dirent => dirent.isDirectory())
  .map(dirent => dirent.name);

console.log("Starting " + command + " for extensions:", extensions);

// Function to execute npm run dev or npm run build for an extension
function runCommandForExtension(extension, cmd) {
  const extensionPath = path.join(extensionsDir, extension);
  console.log("Running " + cmd + "for " + extension + "...");
  return spawn('npm', ['run', cmd], { 
    cwd: extensionPath, 
    stdio: 'inherit',
    shell: true 
  });
}

// Execute the command for each extension
const processes = extensions.map(ext => runCommandForExtension(ext, command));

// Function to check if the dist directory exists for an extension
function checkDistExists(extension) {
  const distPath = path.join(extensionsDir, extension, 'dist');
  return fs.existsSync(distPath);
}

// Function to check all dist directories
function checkAllDists() {
  return extensions.every(checkDistExists);
}

// Function to wait for all dist directories to be created
function waitForDists() {
  return new Promise((resolve) => {
    const checkInterval = setInterval(() => {
      if (checkAllDists()) {
        clearInterval(checkInterval);
        console.log("All dist directories have been created");
        resolve();
      }
    }, 1000);
  });
}

// Wait for all dist directories to be created
waitForDists().then(() => {
  console.log(command + " for extensions completed. Proceeding to the next step.");
  process.exit(0);
});

// Handle process termination
process.on('SIGINT', () => {
  console.log("Stopping all " + command + " processes for extensions...");
  processes.forEach(process => process.kill());
  process.exit(0);
});
EOL

# Create package.json file with appropriate scripts and dependencies
cat > package.json << EOL
{
  "name": "$PROJECT_NAME",
  "version": "1.0.0",
  "description": "Directus Instance - $PROJECT_NAME",
  "scripts": {
    "start": "npm run build-extensions && npx directus start",
    "dev:extensions": "node scripts/dev-extensions.js dev",
    "build-extensions": "node scripts/dev-extensions.js build",
    "dev:root": "nodemon --exec npx directus start --watch extensions",
    "dev": "npm run dev:extensions && npm run dev:root",
    "extension": "cd extensions && npx create-directus-extension@latest"
  },
  "dependencies": {
    "directus": "latest"
  },
   "devDependencies": {
    "nodemon": "latest",
    "concurrently": "latest"
  },
  "engines": {
    "node": "18.x"
  }
}
EOL

echo "Installation completed for project '$PROJECT_NAME'."
echo "The Directus server will run on port $PORT."
echo "Admin email: $ADMIN_EMAIL"
echo "Admin password: $ADMIN_PASSWORD"
echo "A random ADMIN_TOKEN has been generated and saved in the .env file."
echo "Admin token: $ADMIN_TOKEN"
echo "To start the server in development mode with extensions, run: cd $PROJECT_NAME && npm run dev"
echo "To start the server normally, run: cd $PROJECT_NAME && npm start"
echo "Please make sure to change the admin password after your first login."
