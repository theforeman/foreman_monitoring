# Foreman Monitoring Plugin

This is a Foreman plugin for monitoring system integration.
It allows to manage hosts and downtimes and to display status
information from the monitoring solution.

It requires the Smart Proxy plugin [monitoring](https://github.com/theforeman/smart_proxy_monitoring)
for communication with the monitoring system. See its documentation
for supported monitoring solutions and detailed configuration instructions.

# Installation

See [How_to_Install_a_Plugin](http://projects.theforeman.org/projects/foreman/wiki/How_to_Install_a_Plugin)
for how to install Foreman plugins.

The gem name is `foreman_monitoring`.

RPM users can install the `tfm-rubygem-foreman_monitoring` package.

Deb users can install the `ruby-foreman-monitoring` package.

If using the gem as installation source database enhancement and service restart must
be done manually.

```
foreman-rake db:migrate
foreman-rake db:seed
touch ~foreman/tmp/restart.txt
```

## Compatibility

| Foreman Version | Plugin Version |
| --------------- | --------------:|
| >= 1.15         | ~> 0.1         |
| >= 1.17         | ~> 1.0         |

# Usage

For managing a host in the monitoring solution a Smart Proxy providing
the `monitoring` feature has to be assigned. This can be done during
provisioning or as a bulk action from the host overview.

You can configure the default action which will be done during host
provisioning and de-provisioning. Provisioning allows to create a monitoring
object or take no action while de-provisoning allows deleting the monitoring
object, set a downtime or take no action. For rebuild, it will by default
set a downtime.

The plugin will show you the monitoring status as a sub-status and a detail
panel. You can configure if the sub-status should affect the global status.

Furthermore, it allows to individually set a downtime at the host detail view
or as a bulk action from the host overview.

# Troubleshooting

Logging entries relevant to the plug-in will be located in the Foreman's log
which is by default `/var/log/foreman/production.log`.

Also, check the troubleshooting section of the Smart Proxy plug-in if problems
occur in the underlying communication.

## Contributing

Fork and send a Pull Request. Thanks!

# Copyright
Copyright (c) 2016 The Foreman developers

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
