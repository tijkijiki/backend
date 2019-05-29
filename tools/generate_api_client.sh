#!/usr/bin/env bash

SWAGGER_CLI=swagger-codegen-cli.jar

if [[ ! -f ${SWAGGER_CLI} ]]; then
    wget http://central.maven.org/maven2/io/swagger/swagger-codegen-cli/2.4.5/swagger-codegen-cli-2.4.5.jar -O ${SWAGGER_CLI}
fi

java -jar swagger-codegen-cli.jar generate \
   -i ../server/swagger-api.yaml \
   -l dart \
   -o ../api_client \
   -t swagger-tpl/dart \
   -c gen_config.json

dartfmt -w ../api_client/