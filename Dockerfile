arg ODOO_VERSION=18.0
arg DOCKER_BASE_IMAGE=ghcr.io/erpm-bv/odoo-docker:${ODOO_VERSION}-dev

# Create the vscode development image
# python (dev) requirements
from ${DOCKER_BASE_IMAGE} as dev
user root
add requirements-dev.txt /tmp
run cd /tmp \
	&& pip3 install --prefix=/usr --no-cache -r /tmp/requirements-dev.txt \
	&& rm -f /tmp/requirements-dev.txt

# use a single user for both running the container and devcontainer
from dev as vscode
arg DEV_UID=1000
run echo "root:${ADMIN_PASSWORD:-admin}" | chpasswd \
	&& mkdir /odoo-workspace \
	&& ( \
		[ "${DEV_UID}" == "0" ] && \
		useradd -G odoo --create-home vscode || \
		useradd --uid "${DEV_UID}" -G odoo --create-home vscode \
	 ) && chown vscode:odoo /odoo-workspace
user vscode
