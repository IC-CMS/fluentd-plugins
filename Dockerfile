# 
FROM fluent/fluentd:v1.1.3-debian

RUN 	apt-get install -y ruby && \
	echo 'gem: --no-document' >> /etc/gemrc && \
	gem install influxdb && \
	gem install json && \
	gem install kafka && \
	gem install mongo && \
	gem install multi-format-parser && \
	gem install numeric-counter && \
	gem install numeric-monitor && \
	gem install parser && \
	gem install rewrite && \
	gem install rewrite-tag-filter && \
	gem install route && \
	gem install s3 && \
	gem install slack && \
	gem install secure-forward && \
	gem install stats-notifier && \
	rm-rf /tmp/* var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN adduser -D -g "-u 1001 -h /home/fluent fluent

