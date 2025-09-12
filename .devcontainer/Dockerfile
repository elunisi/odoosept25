FROM ubuntu:noble
MAINTAINER Coder/Envbuilder adapted from Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG=en_US.UTF-8

# Retrieve the target architecture to install the correct wkhtmltopdf package
ARG TARGETARCH
ARG ODOO_VERSION=18.0
ARG ODOO_RELEASE=20241101
ARG ODOO_SHA=f8eab5b6d0f2797d0b7f93b6d5bb3a8e2ff6f999

# Install development tools first for better caching
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        build-essential \
        git \
        vim \
        wget \
        sudo \
        && rm -rf /var/lib/apt/lists/*

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-magic \
        python3-num2words \
        python3-odf \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
        python3-xlwt \
        xz-utils \
    && curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb \
    && echo 'b25c5fe62fda5a168a7e1c9e18c76e9b0d9c6fb0 wkhtmltox.deb' | sha1sum -c - \
    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

# Install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ noble-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Odoo
RUN curl -o odoo.deb -sSL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Install development Python packages
RUN pip3 install --break-system-packages \
    debugpy \
    ipdb \
    pylint-odoo \
    black \
    watchdog

# Copy configuration files
COPY .devcontainer/entrypoint.sh /entrypoint.sh
COPY .devcontainer/odoo.conf /etc/odoo/odoo.conf
COPY .devcontainer/wait-for-psql.py /usr/local/bin/wait-for-psql.py

# Set permissions and create directories
RUN chown odoo /etc/odoo/odoo.conf \
    && chmod +x /entrypoint.sh \
    && chmod +x /usr/local/bin/wait-for-psql.py \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons \
    && mkdir -p /workspace \
    && chown -R odoo /workspace

# Add odoo user to sudo for development
RUN usermod -aG sudo odoo \
    && echo "odoo ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Mount volumes for development
VOLUME ["/var/lib/odoo", "/mnt/extra-addons", "/workspace"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC=/etc/odoo/odoo.conf

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
