# frozen_string_literal: true

class MonitoringResult < ApplicationRecord
  enum :result => { :ok => 0, :warning => 1, :critical => 2, :unknown => 3 }

  belongs_to_host

  # rubocop:disable Metrics/AbcSize
  def self.import(result)
    host = Host.find_by(name: result[:host])

    if host.nil?
      logger.error "Unable to find host #{result[:host]}"
      return false
    end

    start_time = Time.now.utc
    logger.info "Processing monitoring result for #{host}"

    updates = {
      :result => result[:result],
      :acknowledged => result[:acknowledged],
      :downtime => result[:downtime],
      :timestamp => (Time.at(result[:timestamp]).utc rescue nil)
    }.compact

    if result[:initial] && result[:service] == 'Host Check'
      logger.info "Removing all monitoring results for #{host} on initial import"
      MonitoringResult.where(:host => host).destroy_all
    end

    created = MonitoringResult.where(:host => host, :service => result[:service]).first_or_create
    if created.timestamp.blank? || updates[:timestamp].blank? || (created.timestamp.to_time - updates[:timestamp].to_time) < 2
      created.update(updates)

      if created.persisted?
        logger.info("Imported monitoring result for #{host} in #{(Time.now.utc - start_time).round(2)} seconds")
        host.get_status(::HostStatus::MonitoringStatus).refresh!
      end
    else
      logger.debug "Skipping monitoring result import for #{host} as it is older than what we have."
    end
  end
  # rubocop:enable Metrics/AbcSize

  def status
    return :ok if downtime
    return :warning if acknowledged

    result.to_sym
  end

  def to_label
    label_mapper(status)
  end

  def to_full_label
    options = []
    options << _('acknowledged') if acknowledged
    options << _('in downtime') if downtime
    suffix = options.any? ? " (#{options.join(', ')})" : ''
    "#{label_mapper(result.to_sym)}#{suffix}"
  end

  private

  def label_mapper(value)
    case value
    when :ok
      _('OK')
    when :warning
      _('Warning')
    when :critical
      _('Critical')
    else
      _('Unknown')
    end
  end
end
