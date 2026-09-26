# frozen_string_literal: true

Deface::Override.new(:virtual_path => 'hosts/_form',
  :name => 'add_monitoring_interface_js',
  :insert_before => 'div#primary',
  :text => '<%= javascript "foreman_monitoring/monitoring_interface" %>')

Deface::Override.new(:virtual_path => 'nic/_base_form',
  :name => 'add_monitoring_interface',
  :insert_after => 'erb[loud]:contains("interface_provision")',
  :partial => 'overrides/nics/monitoring_interface')
