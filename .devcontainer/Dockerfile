FROM odoo:17

USER root

# Set proper user parameters
ARG USERNAME=odoo
ARG USER_UID=1000
ARG USER_GID=1000

# Handle existing user modification or creation
RUN if id -u $USERNAME > /dev/null 2>&1; then \
      groupmod --gid $USER_GID $USERNAME && \
      usermod --uid $USER_UID --gid $USER_GID $USERNAME && \
      chown -R $USER_UID:$USER_GID /var/lib/odoo /mnt/extra-addons || true; \
    else \
      groupadd --gid $USER_GID $USERNAME && \
      useradd --uid $USER_UID --gid $USER_GID -m -s /bin/bash $USERNAME; \
    fi 

# Install sudo and configure permissions
RUN apt-get update && \
    apt-get install -y sudo && \
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    rm -rf /var/lib/apt/lists/*

# Ensure proper directory ownership
RUN mkdir -p /var/lib/odoo /mnt/extra-addons && \
    chown -R $USER_UID:$USER_GID /var/lib/odoo /mnt/extra-addons

USER $USERNAME