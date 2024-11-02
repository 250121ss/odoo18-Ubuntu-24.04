#!/bin/bash

# Odoo 18 Installation Script for Ubuntu 24.04

# Update and upgrade the system
echo "Updating system packages..."
sudo apt update -y

# Install required packages
echo "Installing required packages..."
sudo apt install -y python3-minimal python3-dev python3-pip python3-venv python3-setuptools \
build-essential libzip-dev libxslt1-dev libldap2-dev python3-wheel libsasl2-dev node-less \
libjpeg-dev xfonts-utils libpq-dev libffi-dev fontconfig git wget

# Install and configure PostgreSQL
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql

echo "Starting PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

echo "Creating Odoo PostgreSQL user..."
sudo su - postgres -c "createuser -s odoo"

# Install Node.js and npm
echo "Installing Node.js and npm..."
sudo apt install -y nodejs npm

# Install rtlcss for RTL support
echo "Installing rtlcss..."
sudo npm install -g rtlcss

# Install xfonts dependencies for wkhtmltopdf
echo "Installing xfonts for wkhtmltopdf..."
sudo apt-get install -y xfonts-75dpi xfonts-base

# Create Odoo system user
echo "Creating Odoo system user..."
sudo adduser --system --group --home=/opt/odoo --shell=/bin/bash odoo

# Switch to Odoo user and install Odoo
echo "Cloning Odoo 18 from GitHub..."
sudo su - odoo -c "git clone https://www.github.com/odoo/odoo --depth 1 --branch 18.0 /opt/odoo/odoo"

# Create Python virtual environment
echo "Creating Python virtual environment..."
sudo su - odoo -c "python3 -m venv odoo-env"

# Activate virtual environment and install requirements
echo "Installing Python requirements..."
sudo su - odoo -c "source odoo-env/bin/activate && pip3 install wheel && pip3 install -r /opt/odoo/odoo/requirements.txt"

# Deactivate virtual environment
sudo su - odoo -c "deactivate"

# Create custom addons directory
echo "Creating custom addons directory..."
sudo mkdir /opt/odoo/custom-addons

# Create Odoo log directory
echo "Creating Odoo log directory..."
sudo mkdir /var/log/odoo18
sudo chown odoo:odoo /var/log/odoo18

# Create Odoo configuration file
echo "Creating Odoo configuration file..."
sudo bash -c 'cat <<EOL > /etc/odoo.conf
[options]
admin_passwd = Strong_admin_Password
db_host = False
db_port = False
db_user = odoo
db_password = False
logfile = /var/log/odoo18/odoo-server.log
addons_path = /opt/odoo/odoo/addons,/opt/odoo/custom-addons
xmlrpc_port = 8069
EOL'

# Create systemd service file for Odoo
echo "Creating systemd service file..."
sudo bash -c 'cat <<EOL > /etc/systemd/system/odoo.service
[Unit]
Description=Odoo
Requires=postgresql.service
After=network.target postgresql.service

[Service]
Type=simple
SyslogIdentifier=odoo
PermissionsStartOnly=true
User=odoo
Group=odoo
ExecStart=/opt/odoo/odoo-env/bin/python3 /opt/odoo/odoo/odoo-bin -c /etc/odoo.conf
StandardOutput=journal+console

[Install]
WantedBy=multi-user.target
EOL'

# Reload systemd and start Odoo service
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
echo "Starting Odoo service..."
sudo systemctl start odoo
sudo systemctl enable odoo

# Check Odoo service status
echo "Checking Odoo service status..."
sudo systemctl status odoo

# Final message
echo "Odoo 18 installation complete. Access it at http://your-IP-address:8069"
