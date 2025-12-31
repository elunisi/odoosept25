FROM odoo:18.0

USER root

# make /workspace the home directory of odoo as there the prmissions are set correctly
RUN mkdir -p /home/odoo \
    && chown -R odoo:odoo /home/odoo \
    && usermod -d /home/odoo odoo
    
USER odoo
