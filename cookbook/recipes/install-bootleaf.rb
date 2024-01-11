# Install required packages
package %w(httpd mod_ssl wget zip unzip php mod_auth_mellon mod_auth_openidc)

# Copy Bootleaf files to Apache document root
directory '/var/www/html/bootleaf-twc' do
  recursive true
  action :create
end

cookbook_file '/var/www/html/phpinfo.php' do
  source 'phpinfo.php'
  mode '0644'
  action :create
end

cookbook_file '/etc/httpd/conf.d/auth_openidc.conf' do
  source 'auth_openidc.conf'
  mode '0644'
  action :create
end

# Modify Apache configuration
execute 'disable_default_httpd_conf' do
  command 'sed -i \'s/^Listen 80/#Listen 80/\' /etc/httpd/conf/httpd.conf'
  not_if 'grep -q "^Listen 80" /etc/httpd/conf/httpd.conf'
end

execute 'change_directory_index' do
  command 'sed -i \'s/DirectoryIndex index.html/DirectoryIndex index.htm/\' /etc/httpd/conf/httpd.conf'
  not_if 'grep -q "DirectoryIndex index.htm" /etc/httpd/conf/httpd.conf'
end

execute 'change_custom_log_format' do
  command 'sed -i \'s/CustomLog "logs\\/access_log" combined/CustomLog "logs\\/access_log" common/\' /etc/httpd/conf/httpd.conf'
  not_if 'grep -q "CustomLog \\"logs\\/access_log\\" common" /etc/httpd/conf/httpd.conf'
end

file '/etc/httpd/conf/httpd.conf' do
    content = IO.read('/etc/httpd/conf/httpd.conf')
    # Ensure newline at the end of file for consistency
    content << "\n" unless content.end_with?("\n")
    content << <<-EOH
  <Location /bootleaf-twc/test.htm>
     AuthType openid-connect
     Require valid-user
  </Location>
  <Location /index.htm>
     AuthType openid-connect
     Require valid-user
  </Location>
  <Location />
     AuthType openid-connect
     Require valid-user
  </Location>
  ServerName 127.0.0.1
  EOH
    action :create
  end

# Create the ssl.conf file to the Apache configuration directory
template '/etc/httpd/conf.d/ssl.conf' do
    source 'ssl.conf.erb'  
    mode '0644'
    owner 'root'
    group 'root'  
    notifies :restart, 'service[httpd]'  # Notify Apache to restart after template rendering
end

# Create the SSL certificate and key files
execute 'create_ssl_certificate' do
  command 'openssl req -x509 -nodes -days 365 -subj "/C=CA/ST=QC/O=SUN Inc/CN=localhost.com" -newkey rsa:2048 -keyout /etc/pki/tls/private/localhost.key -out /etc/pki/tls/certs/localhost.crt'
  not_if { ::File.exist?('/etc/pki/tls/private/localhost.key') && ::File.exist?('/etc/pki/tls/certs/localhost.crt') }
end

# Expose port 443 for HTTPS
port '443' do
  action :nothing
end

# Start Apache HTTP Server
service 'httpd' do
  action [:enable, :start]
end
