#
# Cookbook Name:: nginx
# Recipe:: http_ssl_module
#
# Author:: Scott Bader (<scott@gotryiton.com>)
#
# Copyright 2013, Go Try It On, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

syslog_file_path = "#{Chef::Config['file_cache_path'] || '/tmp'}/nginx_syslog_patch"

git "nginx_syslog_patch" do
  repository "git://github.com/gotryiton/nginx_syslog_patch.git"
  revision "2686c1c48c351facdc02282726b2e7d519427673"
  destination syslog_file_path
  not_if { File.exists?(node['nginx']['binary']) || File.directory?(syslog_file_path) }
end

execute "copy syslog patch" do
  command "cp -R #{syslog_file_path} /opt/nginx_syslog_patch"
  creates "/opt/nginx_syslog_patch"
  action :run
end

node.run_state['nginx_syslog'] = true

node.run_state['nginx_configure_flags'] =
  node.run_state['nginx_configure_flags'] | ["--add-module=/opt/nginx_syslog_patch"]

node.run_state['nginx_patches'] =
  node.run_state['nginx_patches'] | ["patch -p1 < /opt/nginx_syslog_patch/syslog_1.2.0.patch"]
