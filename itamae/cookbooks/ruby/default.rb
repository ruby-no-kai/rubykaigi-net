remote_file "/etc/apt/keyrings/sorah-rbpkg.asc" do
  owner 'root'
  group 'root'
  mode '0644'
end

file "/etc/apt/sources.list.d/sorah-ruby.list" do
  content <<EOF
deb [signed-by=/etc/apt/keyrings/sorah-rbpkg.asc] https://cache.ruby-lang.org/lab/sorah/deb/ noble main
EOF
  owner 'root'
  group 'root'
  mode  '0644'
  notifies :run, "execute[apt-get update]", :immediately
end

package 'ruby'
package 'ruby-dev'
package 'build-essential'
package 'cargo'
package 'clang'
