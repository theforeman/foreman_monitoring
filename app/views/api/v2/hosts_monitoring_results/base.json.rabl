object @monitoring_result

attributes :id, :service, :status, :result, :downtime, :acknowledged, :timestamp

node :status_label do |result|
  result.to_label
end
