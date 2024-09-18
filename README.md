# Directus Instance Dev

This bash script automates the setup of a Directus instance for development purposes, including support for multiple extensions.

## Features

- Automatically installs the latest version of Directus
- Actually Directus only supports Node.js 18.x, so the script checks if you have the correct version installed
- Sets up a SQLite database
- Configures environment variables
- Creates an admin user
- Installs development dependencies (nodemon and concurrently)
- Provides options to create and manage Directus extensions
- Sets up development scripts for running Directus with extensions

## Prerequisites

- Node.js and npm installed on your system (engine 18.x)
- Bash shell environment

## Usage

1. Download the `directus-instance-dev.sh` script to your local machine.

2. Make the script executable:
   ```
   chmod +x directus-instance-dev.sh
   ```

3. Run the script:
   ```
   ./directus-instance-dev.sh
   ```

4. Follow the prompts to configure your Directus instance:
   - Enter a project name
   - Specify the port for the Directus server (default is 8055)
   - Provide an admin email and password (or let the script generate a random password)

5. The script will set up your Directus project and provide you with the necessary credentials and instructions.

## Post-Installation

After the script completes, you can:

- Start the Directus server in development mode:
  ```
  cd your-project-name
  npm run dev
  ```

- Start the Directus server normally:
  ```
  cd your-project-name
  npm start
  ```

- Create a new Directus extension:
  ```
  cd your-project-name
  npm run create-extension
  ```

## Scripts

The following npm scripts are available in your project:

- `npm start`: Starts the Directus server
- `npm run dev`: Runs Directus in development mode with extension support
- `npm run dev:extensions`: Starts the development process for all extensions
- `npm run dev:root`: Runs the Directus server with nodemon, watching for changes in extensions
- `npm run extension`: Creates a new Directus extension in the correct directory

## Important Notes

- Remember to change the admin password after your first login for security purposes.
- The script generates random keys for encryption and an admin token. These are saved in the `.env` file.
- The default database is SQLite. If you need a different database, you'll need to modify the `.env` file manually.

## Customization

You can modify the `directus-instance-dev.sh` script to suit your specific needs. Some areas you might want to customize include:

- Database configuration
- Additional environment variables
- Pre-installing specific Directus extensions
- Modifying the development scripts

## Support

If you encounter any issues or have questions about using this script, please open an issue in the project repository or refer to the [Directus documentation](https://docs.directus.io/).

