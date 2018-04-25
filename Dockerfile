# 
FROM fluent/fluentd:v1.1.3-debian
MAINTAINER IC-CMS https://github.com/IC-CMS

RUN apt-get update -y && \
	apt-get install -y curl gnupg build-essential libcurl4-openssl-dev

RUN apt-get install -y ruby`ruby -e 'puts RUBY_VERSION[/\d+\.d+/]'`-dev

# install td-agent
#RUN curl -L http://toolbelt.treasuredata.com/sh/install-

# Install RVM
#RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 && \
#	curl -sSL https://get.rvm.io | bash -s stable && \
#	usermod -a -G rvm root

# Install Ruby and Bundle
#RUN  /usr/local/rvm install ruby &&  /usr/local/rvm --default use ruby && \
#	gem install bundler --no-rdoc --no-ri

# https://www.ruby-lang.org/en/documentation/installation/#apt

# gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.2;

RUN 	echo 'gem: --no-rdoc --no-ri' >> /etc/gemrc && \
	fluent-gem install amqp && \
	fluent-gem install cloudwatch && \
	fluent-gem install cloudwatchlogger && \
	gem install fluent-plugin-elasticsearch && \
	fluent-gem install influxdb && \
	fluent-gem install json && \
	fluent-gem install kafka && \
	fluent-gem install mongo && \
	fluent-gem install parser && \
	fluent-gem install rewrite && \
	fluent-gem install s3 && \
	fluent-gem install slack && \
	fluent-gem install forward && \
	fluent-gem install fluent-plugin-secure-forward && \
	fluent-gem install fluent-plugin-notifier && \
	rm -rf /tmp/* var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

#adduser --system [--home DIR] [--shell SHELL] [--no-create-home] [--uid ID]
#[--gecos GECOS] [--group | --ingroup GROUP | --gid ID] [--disabled-password]
#[--disabled-login] [--add_extra_groups] USER

#RUN addgroup --system --gid 1001 fluent && \
#    adduser --system --uid 1001 --gid 1001  --shell /usr/sbin/nologin  fluent


CMD ["/bin/entrypoint.sh"]
#CMD /etc/init.d/td-agent stop && /opt/td-agent/embedded/bin/fluentd -c /etc/fluentd/fluent.conf
