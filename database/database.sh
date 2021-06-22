#!/bin/bash
# references
# https://hub.docker.com/_/mysql

PORT="3306"
IP="127.0.0.1"
DB_FILE="db.sql"
IMAGE_VERSION="8.0.25"
DOCKER_NAME="node-mysql-api"
MYSQL_ROOT_PASSWORD="{{username}}"


success(){
	echo -e "[\e[32mSUCCESS\e[0m] $@"
}

info(){
	echo -e "[\e[36mINFO\e[0m]	  $@"
}

failed(){
	echo -e "[\e[31mFAILED\e[0m]  $@" >&2
	exit 1
}

import_database(){
	info "Importing database ($DB_FILE)"
	[ ! -f "$DB_FILE" ] && failed "$DB_FILE not foud"

	docker cp $DB_FILE "$DOCKER_NAME":/

	local script
	read -d '' -r script <<-EOF
	# wait for start mysql
	while ! mysql -u root -p$MYSQL_ROOT_PASSWORD -e "SELECT 1"; do
		sleep 0.5
	done >/dev/null 2>&1

	mysql -u root -p$MYSQL_ROOT_PASSWORD < $DB_FILE 2>/dev/null
	if [ $? -eq 0 ]; then
		echo -e "[\e[32mSUCCESS\e[0m] Database imported"
	else
		echo -e "[\e[31mFAILED\e[0m]  Database not imported" 1>&2
		exit 1
	fi
	EOF

	docker exec "$DOCKER_NAME" bash -c "$script" || exit 1;
}

build(){
	info "Building Docker container $DOCKER_NAME"

	[ ! -f "$DB_FILE" ] && failed "$DB_FILE not foud"

	docker run --name "$DOCKER_NAME" --restart unless-stopped \
		--env MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
		--publish "${IP}:${PORT}:3306" --detach mysql:$IMAGE_VERSION &&\
		success "Container builded $DOCKER_NAME" || \
		failed "Container not builded $DOCKER_NAME"

	import_database
}

start(){
	info "Starting docker container $DOCKER_NAME"
	docker start "$DOCKER_NAME" &&	success "Container started" || 	failed "Conteiner not started"
}

stop(){
	info "Stopping docker container $DOCKER_NAME"
	docker stop "$DOCKER_NAME" && success "Container stoped" || failed "Conteiner not stoped"
}

clean(){
	info "Stopping docker container $DOCKER_NAME"
	docker stop $DOCKER_NAME 2>/dev/null

	info "Removing docker container $DOCKER_NAME"
	docker rm $DOCKER_NAME 2>/dev/null && success "Container removed"|| failed "Conteiner not removed"
}

prompt(){
	echo "DATABASE NAME: example_api"

	docker exec --interactive --tty $DOCKER_NAME mysql -p"$MYSQL_ROOT_PASSWORD" --database=example_api || failed
}

show_help(){
	cat <<-EOF
	Usage: $0 COMMAND
	Commands:
	  build  - build the database docker container
	  start  - start the database docker container
	  stop   - stop the database docker container
	  clean  - remove the docker container
	  prompt - execute prompt mysql
	EOF
	exit 0
}

cd ${0%/*}/

if [ $# -eq 0 ]; then
	if $(docker ps -a --format={{.Names}} | grep -qw "$DOCKER_NAME"); then
		start
	else
		build
	fi

	exit 0
fi

[ $# -ne 1 ] && show_help

case "$1" in
	"build")  build;;
	"start")  start;;
	"stop")   stop;;
	"clean")  clean;;
	"prompt") prompt;;
	*)		show_help;;
esac
