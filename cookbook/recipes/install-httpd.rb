# Install required packages
package %w(openssl zip java maven wget procps sudo vim)

# Download and extract GeoServer
remote_file '/tmp/geoserver-2.18.1-bin.zip' do
  source 'http://sourceforge.net/projects/geoserver/files/GeoServer/2.18.1/geoserver-2.18.1-bin.zip'
  mode '0644'
  action :create
end

execute 'extract_geoserver' do
  command 'unzip /tmp/geoserver-2.18.1-bin.zip -d /opt/geoserver'
  not_if { ::File.exist?('/opt/geoserver') }
end

# Set permissions and ownership
user 'gis' do
  action :create
end

execute 'add_sudoers_entry' do
  command 'echo "gis ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers'
  not_if 'grep -q "gis ALL=(ALL) NOPASSWD:ALL" /etc/sudoers'
end

directory '/opt/geoserver' do
  owner 'gis'
  group 'gis'
  recursive true
  action :create
end

# Start GeoServer
# Create GeoServer service
systemd_unit 'geoserver.service' do
    content ({
      Unit: {
        Description: 'GeoServer',
        After: [
            'network.target',
            'multi-user.target'
        ],
      },
      Service: {
        User: 'gis',
        ExecStart: '/opt/geoserver/bin/startup.sh',
        WorkingDirectory: '/opt/geoserver',
        Restart: 'always',
        Environment: [
          'GEOSERVER_HOME=/opt/geoserver',
          'JAVA_HOME=/etc/alternatives/java_sdk_openjdk'
        ],
      }
    })
    action [:create, :enable, :start]
end