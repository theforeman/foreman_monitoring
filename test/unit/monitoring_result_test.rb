require 'test_plugin_helper'

class MonitoringResultTest < ActiveSupport::TestCase
  setup do
    User.current = FactoryBot.build(:user, :admin)
    setup_settings
    disable_orchestration
    disable_monitoring_orchestration
  end

  context '#import' do
    let(:host) { FactoryBot.create(:host, :managed, :with_monitoring) }

    let(:initial) do
      {
        host: host.name,
        service: 'cpu metrics',
        timestamp: 1_516_365_380.8834700584,
        result: 1,
        acknowledged: true
      }
    end

    let(:acknowledegment_cleared) do
      {
        host: host.name,
        service: 'cpu metrics',
        timestamp: 1_516_365_971.2455039024,
        acknowledged: false
      }
    end

    let(:state_change) do
      {
        host: host.name,
        service: 'cpu metrics',
        timestamp: 1_516_365_971.2461779118,
        result: 0
      }
    end

    test 'imports a monitoring result' do
      MonitoringResult.import(initial)
      imported = host.monitoring_results.last
      assert_equal true, imported.acknowledged?
    end

    test 'handles ack and state change in correct order' do
      MonitoringResult.import(initial)
      MonitoringResult.import(acknowledegment_cleared)
      MonitoringResult.import(state_change)
      imported = host.monitoring_results.last
      assert_equal :ok, imported.status
      assert_equal false, imported.acknowledged?
    end

    test 'handles ack and state change in reverse order' do
      MonitoringResult.import(initial)
      MonitoringResult.import(state_change)
      MonitoringResult.import(acknowledegment_cleared)
      imported = host.monitoring_results.last
      assert_equal :ok, imported.status
      assert_equal false, imported.acknowledged?
    end

    test 'ignores old data' do
      MonitoringResult.import(state_change)
      MonitoringResult.import(initial)
      imported = host.monitoring_results.last
      assert_equal false, imported.acknowledged?
    end
  end
end
