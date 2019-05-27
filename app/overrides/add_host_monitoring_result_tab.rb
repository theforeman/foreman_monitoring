Deface::Override.new(:virtual_path => 'hosts/show',
                     :name => 'add_monitoring_result_tab',
                     :insert_bottom => 'ul.nav-tabs',
                     :partial => 'monitoring_results/host_tab')

Deface::Override.new(:virtual_path => 'hosts/show',
                     :name => 'add_monitoring_result_tab_pane',
                     :insert_bottom => 'div.tab-content',
                     :partial => 'monitoring_results/host_tab_pane')
