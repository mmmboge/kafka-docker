#!/bin/bash

echo -e "\033[43;31mkafka will start without zookeeper....\033[0m"

export KAFKA_HOME=.
EXCLUSIONS="|KAFKA_VERSION|KAFKA_HOME|KAFKA_DEBUG|KAFKA_GC_LOG_OPTS|KAFKA_HEAP_OPTS|KAFKA_JMX_OPTS|KAFKA_JVM_PERFORMANCE_OPTS|KAFKA_LOG|KAFKA_OPTS|"


function updateConfig() {
        key=$1
        value=$2
        file=$3

        # Omit $value here, in case there is sensitive information
        echo "[Configuring] '$key'[$value] in '$file'"

        # If config exists in file, replace it. Otherwise, append to file.
        if grep -E -q "^#?$key=" "$file"; then
                sed -r -i "s|^#?$key=.*|$key=$value|g" "$file" #note that no config values may contain an '@' char
        else
                echo "$key=$value" >> "$file"
        fi
}

IFS=$'\n'
for VAR in $(env)
do
    env_var=$(echo "$VAR" | cut -d= -f1)
    echo env_var is $env_var
    if [[ "$EXCLUSIONS" = *"|$env_var|"* ]]; then
	    echo "Excluding $env_var from broker config"
	    continue
    fi
    if [[ $env_var =~ ^KAFKA_ ]]; then
	    kafka_name=$(echo "$env_var" | cut -d_ -f2- | tr '[:upper:]' '[:lower:]' | tr _ .)
	    echo "kafka_name is $kafka_name"
	    updateConfig "$kafka_name" "${!env_var}" "$KAFKA_HOME/config/kraft/server.properties"
    fi   

done

if [[ -z "$KAFKA_CLUSTER_ID" ]]; then
    
    export KAFKA_CLUSTER_ID="$(bin/kafka-storage.sh random-uuid)"
fi

bin/kafka-storage.sh format -t $KAFKA_CLUSTER_ID -c config/kraft/server.properties


exec "$KAFKA_HOME/bin/kafka-server-start.sh" "$KAFKA_HOME/config/kraft/server.properties"
