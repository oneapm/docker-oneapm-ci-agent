#!/bin/bash
set -e

# deal with redis
if [[ $REDIS_PORT ]]; then
	redis_config=/etc/oneapm-ci-agent/conf.d/redisdb.yaml
	redis_addr=`echo $REDIS_PORT | cut -d : -f 2`
	redis_addr=${redis_addr:2}
	redis_port=`echo $REDIS_PORT | cut -d : -f 3`

	cp ${redis_config}.example $redis_config
	# host
	sed -i -e "s/^  - host: localhost/  - host: ${redis_addr}/" $redis_config
	# port
	sed -i -e "s/^    port: 6379/    port: ${redis_port}/" $redis_config
	# TODO: multi instances
fi

# deal with mysql
if [[ $MYSQL_PORT ]]; then
	mysql_config=/etc/oneapm-ci-agent/conf.d/mysql.yaml
	mysql_addr=`echo $MYSQL_PORT | cut -d : -f 2`
	mysql_addr=${mysql_addr:2}
	mysql_port=`echo $MYSQL_PORT | cut -d : -f 3`
	mysql_user='root'
	if [[ $MYSQL_ENV_MYSQL_ALLOW_EMPTY_PASSWORD == 'yes' ]];then
		mysql_pass=''
  else
		mysql_pass=$MYSQL_ENV_MYSQL_ROOT_PASSWORD
	fi

	cp ${mysql_config}.example $mysql_config
	# host
	sed -i -e "s/^  - server: localhost/  - server: ${mysql_addr}/" $mysql_config
	# port
	sed -i -e "s/^    # port: 3306/    port: ${mysql_port}/" $mysql_config
	# user
	sed -i -e "s/^    # user: my_username/    user: ${mysql_user}/" $mysql_config
	# pass
	sed -i -e "s/^    # pass: my_password/    pass: ${mysql_pass}/" $mysql_config
fi

# deal with nginx
if [[ $NGINX_PORT ]]; then
	nginx_config=/etc/oneapm-ci-agent/conf.d/nginx.yaml
	nginx_addr=`echo $NGINX_PORT | cut -d : -f 2`
	nginx_addr=${nginx_addr:2}
	nginx_port=`echo $NGINX_PORT | cut -d : -f 3`

	cp $nginx_config.example $nginx_config
	# url
	sed -i -e "s/^  - nginx_status_url:.*/  - nginx_status_url: http:\/\/${nginx_addr}:${nginx_port}\/nginx_status/" $nginx_config
fi

# deal with postgres
if [[ $POSTGRES_PORT ]];then
	postgres_config=/etc/oneapm-ci-agent/conf.d/postgres.yaml
	postgres_addr=`echo $POSTGRES_PORT | cut -d : -f 2`
	postgres_addr=${postgres_addr:2}
	postgres_port=`echo $POSTGRES_PORT | cut -d : -f 3`
	if [[ $POSTGRES_ENV_POSTGRES_USER ]];then
		postgres_user=$POSTGRES_ENV_POSTGRES_USER
	else
		postgres_user=postgres
	fi
	postgres_pass=$POSTGRES_ENV_POSTGRES_PASSWORD

	cp $postgres_config.example $postgres_config
	# host
	sed -i -e "s/^  - host: localhost/  - host: ${postgres_addr}/" $postgres_config
	# port
	sed -i -e "s/^    port: 5432/    port: ${postgres_port}/" $postgres_config
	# user
	sed -i -e "s/^#    username: my_username/    username: ${postgres_user}/" $postgres_config
	# pass
	sed -i -e "s/^#    password: my_password/    password: ${postgres_pass}/" $postgres_config
fi

# deal memcached
if [[ $MEMCACHED_PORT ]];then
	memcached_config=/etc/oneapm-ci-agent/conf.d/mcache.yaml
	memcached_addr=`echo $MEMCACHED_PORT | cut -d : -f 2`
	memcached_addr=${memcached_addr:2}
	memcached_port=`echo $MEMCACHED_PORT | cut -d : -f 3`

	cp $memcached_config.example $memcached_config
	# host
	sed -i -e "s/^  - url: localhost/  - url: ${memcached_addr}/" $memcached_config
	# port
  sed -i -e "s/^  #   port: 11211/    port: 11211/" $memcached_config
fi
