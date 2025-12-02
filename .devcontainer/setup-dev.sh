#!/bin/bash
set -e

echo "Setting up Odoo development environment..."

# Create necessary directories
mkdir -p /workspaces/{addons,data,logs,filestore}
chmod 755 /workspaces/{addons,data,logs,filestore}

# Install additional development dependencies
pip3 install --break-system-packages --user \
    pytest \
    coverage \
    pre-commit \
    isort

# Setup git hooks if .git exists
if [ -d "/workspaces/.git" ]; then
    cd /workspace
    pre-commit install
fi

# Create default addon structure if addons directory is empty
if [ -z "$(ls -A /workspaces/addons 2>/dev/null)" ]; then
    mkdir -p /workspaces/addons/custom_addon
    cat > /workspaces/addons/custom_addon/__manifest__.py << 'EOF'
{
    'name': 'Custom Development Module',
    'version': '1.0',
    'depends': ['base'],
    'data': [],
    'installable': True,
    'auto_install': False,
}
EOF
    cat > /workspaces/addons/custom_addon/__init__.py << 'EOF'
# Custom development module
EOF
fi

# Set proper ownership
sudo chown -R odoo:odoo /workspaces

echo "Development environment setup complete!"
