FROM centos:centos7
MAINTAINER t.obara <obara7802@gmail.com>
# for Docker version
# Client version: 0.11.1-dev
# Client API version: 1.12
# docker-0.11.1-22.el7.centos.x86_64

# build: sudo docker build -t repo:1.0 repo
# run: sudo docker run -d -p 8880:80 -v /usr/local/ssl:/usr/local/ssl repo:1.0
#  ローカルリポジトリへアクセスする際のポートは5100がデフォルト
#  変更したい場合、REP_HOST_PORTを設定する事。
#   sudo docker run -d -p 8880:80 -e REP_HOST_PORT=5500 -v /usr/local/ssl:/usr/local/ssl repo:1.0

# laravel4 開発 環境構築

WORKDIR /usr/local/bin
RUN curl -OL http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
RUN rpm -ivh epel-release-7-2.noarch.rpm
# RUN set -x && 'curl -sS https://getcomposer.org/installer | php'
COPY composer.phar /usr/local/bin/

RUN yum --enablerep=epel install httpd openssl mod_ssl php php-mcrypt php-mysql php-pdo git supervisor -y

## setup supervisord
RUN echo '[program:httpd]' > /etc/supervisord.d/httpd.ini
RUN echo 'command=/sbin/httpd -DFOREGROUND' >> /etc/supervisord.d/httpd.ini
RUN echo 'autostart=true' >> /etc/supervisord.d/httpd.ini
RUN echo 'autorestart=true' >> /etc/supervisord.d/httpd.ini
RUN echo 'redirect_stderr=true' >> /etc/supervisord.d/httpd.ini

# comment out default DocumentRoot
RUN sed -ir 's/^DocumentRoot /#DocumentRoot /' /etc/httpd/conf/httpd.conf

WORKDIR /usr/share
RUN git clone https://github.com/0bara/docker-registry-ui.git repo
WORKDIR /usr/share/repo/laravel
RUN composer.phar update
RUN chmod -R 777 app/storage/

RUN echo 'DocumentRoot /usr/share/repo/laravel/public' > /etc/httpd/conf.d/repo.conf
RUN echo '<Directory "/usr/share/repo/laravel/public">' >> /etc/httpd/conf.d/repo.conf
RUN echo '  AllowOverride All' >> /etc/httpd/conf.d/repo.conf
RUN echo '  Require all granted' >> /etc/httpd/conf.d/repo.conf
RUN echo '</Directory>' >> /etc/httpd/conf.d/repo.conf

WORKDIR /usr/share/repo
RUN chown -R apache:apache .

ADD start.sh /
CMD ["/bin/bash","/start.sh"]

EXPOSE 443 80

