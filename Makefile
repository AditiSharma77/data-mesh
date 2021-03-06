# versions
PRESTO_VERSION := 333
export PATH := $(shell pwd)/tmp:$(PATH)


# start commands
up: clean update-box
	SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant up --provision

update-box:
	@SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant box update || (echo '\n\nIf you get an SSL error you might be behind a transparent proxy. \nMore info https://github.com/fredrikhgrelland/vagrant-hashistack/blob/master/README.md#if-you-are-behind-a-transparent-proxy\n\n' && exit 2)

test: clean update-box
	ANSIBLE_ARGS='--extra-vars "mode=test"' SSL_CERT_FILE=${SSL_CERT_FILE} CURL_CA_BUNDLE=${CURL_CA_BUNDLE} vagrant up --provision

# clean commands
destroy-box:
	vagrant destroy -f

remove-tmp:
	rm -rf ./tmp

clean: destroy-box remove-tmp

# start proxies
copy-consul:
	if [ ! -f "./tmp/consul" ]; then mkdir -p ./tmp; vagrant ssh -c "cp /usr/local/bin/consul /vagrant/tmp/consul"; fi;

connect-to-hive: copy-consul
	consul connect proxy -service user -upstream hive-server:8070 -log-level debug
connect-to-presto: copy-consul
	consul connect proxy -service user -upstream presto:8080 -log-level debug
connect-to-minio: copy-consul
	consul connect proxy -service user -upstream minio:8090 -log-level debug
connect-to-hue: copy-consul
	consul connect proxy -service user -upstream hue-server:8888 -log-level debug
connect-to-sqlpad: copy-consul
	consul connect proxy -service user -upstream sqlpad-server:3000 -log-level debug

download-presto-cli:
	wget https://repo1.maven.org/maven2/io/prestosql/presto-cli/${PRESTO_VERSION}/presto-cli-${PRESTO_VERSION}-executable.jar
	mv presto-cli-${PRESTO_VERSION}-executable.jar presto && chmod +x presto &&	mkdir -p ./bin && mv presto ./bin

presto-cli:
	./bin/presto  --http-proxy 127.0.0.1:8080 --catalog hive --schema default
