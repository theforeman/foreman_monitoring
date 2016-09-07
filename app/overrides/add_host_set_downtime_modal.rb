Deface::Override.new(:virtual_path  => 'hosts/show',
                     :name          => 'add_monitoring_set_downtime_modal',
                     :insert_after => 'div#review_before_build',
                     :partial       => 'hosts/set_host_downtime'
                    )
