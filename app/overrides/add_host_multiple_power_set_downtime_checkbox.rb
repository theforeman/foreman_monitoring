# frozen_string_literal: true

Deface::Override.new(:virtual_path => 'hosts/select_multiple_power_state',
                     :name => 'add_host_multiple_power_set_downtime_checkbox',
                     :insert_before => "erb[silent]:contains('end')",
                     :partial => 'hosts/host_downtime_checkbox')
