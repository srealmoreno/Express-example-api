#!/bin/bash
# references:
# https://docs.docker.com/engine/install/debian/
# https://www.freedesktop.org/software/systemd/man/os-release.html

success(){
	echo -e "[\e[32mSUCCESS\e[0m] $@"
}

info(){
	echo -e "[\e[36mINFO\e[0m]    $@"
}

failed(){
	echo -e "[\e[31mFAILED\e[0m]  $@" >&2
	chown $SUDO_USER:$SUDO_USER -R .
	exit 1
}

add_gpg_docker(){
	info "Importing docker gpg Key"
	wget -qO- https://download.docker.com/linux/ubuntu/gpg | \
		gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/docker-keyring.gpg

	if [ $? -eq 0  ]; then
		success "Key imported in /etc/apt/trusted.gpg.d/docker-keyring.gpg"
	else
		failed "key not imported"
	fi
}

add_repo_docker(){
	local DISTRO=$(grep -oP "(?<=\bID=).*" /etc/os-release)
	local VERSION=$(grep -oP "(?<=VERSION_CODENAME=).*" /etc/os-release)

	info "Importing docker repo"
	tee /etc/apt/sources.list.d/docker.list >/dev/null <<-EOF
	#Repository added by Salvador Real script (Android)
	deb [arch=amd64] https://download.docker.com/linux/$DISTRO $VERSION stable
	EOF

	if [ $? -eq 0  ]; then
		success "Repo imported in /etc/apt/sources.list.d/docker.list"
	else
		failed "Repo not imported"
	fi
}

install_docker(){
	info "Installing Docker"

	if ! command -v docker &> /dev/null; then
		add_gpg_docker
		add_repo_docker
		apt update && apt install -y docker-ce docker-ce-cli containerd.io
		if [ $? -eq 0  ]; then
			success "Docker installed"
		else
			failed "Docker not installed"
		fi
	else
		success "Docker is already installed: $(docker -v)"
	fi

	usermod -aG docker $SUDO_USER
}

import_mysql_image(){
	info "Importing mysql image"
	local VERSION="8.0.25"
	local IMAGE_ID=$(docker image list --filter=reference=mysql:$VERSION --quiet)
	if [ "$IMAGE_ID" == ""  ]; then
		docker pull mysql:$VERSION && success "mysql image imported" || failed "mysql image not imported"
	else
		success "Image is already imported: mysql:$VERSION id=$IMAGE_ID"
	fi

}

update_npm(){
	info "Updating npm"
	npm install --global npm
	npm completion | tee /usr/share/bash-completion/completions/npm >/dev/null
}

install_node(){
	info "Installing Nodejs"
	if ! command -v node &> /dev/null; then
		wget -q https://install-node.vercel.app/lts -O install-node && chmod +x install-node
		./install-node -y
		if [ $? -eq 0  ]; then
			success "Nodejs installed"
			update_npm
		else
			failed "Nodejs not installed"
		fi
		rm -f install-node
	else
		success "Nodejs is already installed: node $(node -v)"
	fi
}

install_node_modules(){
	info "Installing modules (Express, mysql, nodemon)"
	npm install -D
	if [ $? -eq 0  ]; then
		success "Modules installed"
	else
		failed "Modules not installed"
	fi
	chown $SUDO_USER:$SUDO_USER -R .
}

change_credentials(){
	local USERNAME="$SUDO_USER"
	sed -i "s/{{username}}/$USERNAME/g" database/database.sh database/db.sql database/keys.js
}

build_project(){
	cd ${0%/*}/..

	change_credentials

	install_node
	install_node_modules

	install_docker
	import_mysql_image

	database/database.sh || exit 1
	success "Build Success"

	echo "npm start   #start server"
	echo "npm run dev #start server and automatic restart"
}

[ "$EUID" -ne 0 ] && failed "root permision is required.\nsudo $0"

build_project
