execute "apt-get" do
  command "apt-get update"
end

packages = %w{git subversion nginx php5 php5-mysql  php5-pgsql php5-curl php5-mcrypt php5-cli php5-fpm php-pear mysql-server postgresql curl imagemagick php5-imagick php5-common php5-intl php5-sqlite}

packages.each do |pkg|
  package pkg do
    action [:install, :upgrade]
    version node[:versions][pkg]
  end
end

execute "composer-install" do
  command "curl -sS https://getcomposer.org/installer | php ;mv composer.phar /usr/local/bin/composer"
  not_if { ::File.exists?("/usr/local/bin/composer")}
end

execute "phpunit-install" do
  command "composer global require 'phpunit/phpunit=4.5.*'"
  not_if { ::File.exists?("/usr/bin/phpunit")}
end

template "/etc/nginx/conf.d/php-fpm.conf" do
  mode 0644
  source "php-fpm.conf.erb"
end

file "/etc/php5/fpm/pool.d/www.conf" do
  action :delete
end

template "/etc/php5/fpm/pool.d/www2.conf" do
  mode 0644
  source "www2.conf.erb"
end

template "/etc/php5/cli/conf.d/timezone.ini" do
  mode 0644
  source "timezone.ini.erb"
end

service 'apache2' do
  action :stop
end

%w{mysql postgresql php5-fpm nginx}.each do |service_name|
    service service_name do
      action [:start, :restart]
    end
end
