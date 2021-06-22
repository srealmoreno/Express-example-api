#!/bin/bash
# references:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Type
# https://en.wikipedia.org/wiki/Media_type

: "${IP=127.0.0.1}"
: "${PORT=3000}"

n=$(printf '\e[0m')
y=$(printf '\e[33m')
g=$(printf '\e[35m')
b=$(printf '\e[36m')
p=$(printf '\e[32m')

shopt -s nocasematch

get_id(){
	shift
	while [ $# -ne 0 ]; do
		case $1 in
			-i|--id)
				id="$2"
				shift 2
				;;
			*)
				cat <<-EOF
				Unrecognized flag: $1
				Usage:
				-i, --i     		set id
				EOF
				exit 1
				;;
		esac
	done

	if [ -z $id ]; then
		read -p "Insert userId -> " id
	fi

}

get_values(){
	shift
	while [ $# -ne 0 ]; do
		case $1 in
			-f|--firstName)
				firstName="$2"
				shift 2
				;;
			-l|--lastName)
				lastName="$2"
				shift 2
				;;
			-e|--email)
				email="$2"
				shift 2
				;;
			-j|--json)
				json=1
				shift
				;;
			*)
				cat <<-EOF
				Unrecognized flag: $1
				Usage:
				-f, --firstname		set firstname
				-l, --lastname		set lastname
				-e, --email 		set email
				-j, --json   		send request in json format
				EOF
				exit 1
				;;
		esac
	done

	if [ -z "$firstName" ]; then
		read -p "Insert first name-> " firstName
	fi

	if [ -z $lastName ]; then
		read -p "Insert last name-> " lastName
	fi

	if [ -z $email ]; then
		read -p "Insert email-> " email
	fi


}

get_id_with_values(){
	shift
	while [ $# -ne 0 ]; do
		case $1 in
			-i|--id)
				id="$2"
				shift 2
				;;
			-f|--firstName)
				firstName="$2"
				shift 2
				;;
			-l|--lastName)
				lastName="$2"
				shift 2
				;;
			-e|--email)
				email="$2"
				shift 2
				;;
			-j|--json)
				json=1
				shift
				;;
			*)
				cat <<-EOF
				Unrecognized flag: $1
				Usage:
				-i, --id   			set id
				-f, --firstname		set firstname
				-l, --lastname		set lastname
				-e, --email 		set email
				-j, --json   		send request in json format
				EOF
				exit 1
				;;
		esac
	done

	if [ -z "$id" ]; then
		read -p "Insert userId-> " id
	fi


	if [ -z "$firstName" ]; then
		read -p "Insert first name-> " firstName
	fi

	if [ -z $lastName ]; then
		read -p "Insert last name-> " lastName
	fi

	if [ -z $email ]; then
		read -p "Insert email-> " email
	fi

}

getAll(){
	echo -e "${g}curl$n -s ${y}$IP:$PORT/api/users$n | ${g}jq$n\n"

	curl -s $IP:$PORT/api/users | jq
}

get(){
	local id

	get_id "$@"

	echo -e "${g}curl${n} -s ${y}$IP:$PORT/api/users/$id${n} | ${g}jq${n}\n"

	curl -s $IP:$PORT/api/users/$id | jq
}

post(){
	local firstName lastName email json
	get_values "$@"

	if [[ $json -eq 0 ]]; then

		cat <<-EOF
		${g}curl${n} -s -X ${y} POST $IP:$PORT/api/users${n} \\
		--data "${b}firstName${n}=${p}$firstName${n}&${b}lastName${n}=${p}$lastName${n}&${b}email${n}=${p}$email${n}" | ${g}jq${n}

		EOF

		curl -s -X POST $IP:$PORT/api/users \
			--data "firstname=$firstName&lastName=$lastName&email=$email" | jq

	else
		cat<<-EOF
		${g}curl${n} -X ${y}POST $IP:$PORT/api/users${n} \\
		-H ${y}"Content-Type:application/json"${n} \\
		--data '{ ${b}"firstname"${n}:${p}"$firstName"${n}, ${b}"lastname"${n}:${p}"$lastName"${n}, ${b}"email"${n}:${p}"$email"${n} }' | ${g}jq${n}

		EOF

		curl -s -X POST 127.0.0.1:3000/api/users \
			-H "Content-Type:application/json" \
			--data '{ "firstname":"'"$firstName"'", "lastname":"'"$lastName"'", "email":"'"$email"'" }' | jq
	fi

}

set(){
	local firstName lastName email json
	get_values "$@"

	firstName="${firstName// /%20}"
	lastName="${lastName// /%20}"
	email="${email// /%20}"

	echo -e "${g}curl${n} -s ${y}$IP:$PORT/api/user${n}?${b}firstName${n}=${p}$firstName${n}&${b}lastName${n}=$lastName${n}&${b}email${n}=$email | ${g}jq${n}\n"

	curl -s "$IP:$PORT/api/user?firstName=$firstName&lastName=$lastName&email=$email" | jq
}

put(){
	local id firstName lastName email json

	get_id_with_values "$@"

	if [[ $json -eq 0 ]]; then
		cat<<-EOF
		${g}curl${n} -s -X ${yelow}PUT $IP:$PORT/api/users/$id${n} \\
		--data "${b}firstName${n}=${p}$firstName${n}&${b}lastName${n}=${p}$lastName${n}&${b}email${n}=${p}$email${n}" | ${g}jq${n}

		EOF

		curl -s -X PUT $IP:$PORT/api/users/$id \
			--data "firstname=$firstName&lastName=$lastName&email=$email" | jq

	else
		cat<<-EOF
		${g}curl${n} -X ${y}PUT $IP:$PORT/api/users/$id${n} \\
		-H ${y}"Content-Type:application/json"${n} \\
		--data '{ ${b}"firstname"${n}:${p}"$firstName"${n}, ${b}"lastname"${n}:${p}"$lastName"${n}, ${b}"email"${n}:${p}"$email"${n} }' | ${g}jq${n}

		EOF

		curl -s -X PUT 127.0.0.1:3000/api/users/$id \
			-H "Content-Type:application/json" \
			--data '{ "firstname":"'"$firstName"'", "lastname":"'"$lastName"'", "email":"'"$email"'" }' | jq
	fi


}

delete(){
	local id
	get_id "$@"

	echo -e "${g}curl${n} -s -X ${y}DELETE $IP:$PORT/api/users/$id${n} | ${g}jq${n}\n"

	curl -s -X DELETE $IP:$PORT/api/users/$id | jq
}

show_help(){
	cat <<-EOF
	Usage: $0 COMMAND
	Commands:
	  getall - get all users     (GET    METHOD)
	  get    - get user by id    (GET    METHOD)
	  post   - insert new user   (POST   METHOD)
	  set    - insert new user   (SET    METHOD)
	  put    - update user by id    (PUT    METHOD)
	  delete - delete user by id (DELETE METHOD)

	curl help:
	──────────────────────────────────────────────────────────────────────────────────────
	 Request method:
	          ╭─ Specify Request method (${y}GET ${n}|${y} POST ${n}|${y} PUT ${n}|${y} DELETE${n}) default: ${y}GET
	 ${g}curl${n} -s -X ${y}PUT $IP:$PORT/api/user${n}
	       ╰─ Silent (Hidden time)
	──────────────────────────────────────────────────────────────────────────────────────
	 HTTP data:
	 			 ${b}Key ─╮         ${p}╭─ Value
	 ${g}curl${n} --data "${b}firstName${n}=${p}Salvador${n}&${b}lastName${n}=${p}Real${n}"
	         ╰─ HTTP POST data
	──────────────────────────────────────────────────────────────────────────────────────
	 Set json encoding:
	       ╭─ Pass custom header(s) to server
	 ${g}curl${n} -H ${y}"Content-Type:application/json"${n}
	 --data '{ ${b}"firstname"${n}:${p}"Salvador"${n}, ${b}"lastname"${n}:${p}"Real"${n} }'
	           ${b}Key ─╯ 	   ${p}╰─ Value${n}
	──────────────────────────────────────────────────────────────────────────────────────
	EOF

	exit 0
}

[ $# -eq 0 ] && show_help

case "$1" in
	"getall")
		getAll
		;;

	"get")
		get "$@"
		;;

	"post")
		post "$@"
		;;

	"set")
		set "$@"
		;;

	"put")
		put "$@"
		;;

	"delete")
		delete "$@"
		;;

	* )
		show_help
		;;
esac
