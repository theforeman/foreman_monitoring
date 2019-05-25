FactoryBot.modify do
  factory :host do
    trait :with_monitoring do
      monitoring_proxy do
        FactoryBot.create(:smart_proxy, :monitoring)
      end
    end

    trait :with_monitoring_results do
      transient do
        monitoring_result_count { 20 }
      end
      after(:create) do |host, evaluator|
        evaluator.monitoring_result_count.times do
          FactoryBot.create(:monitoring_result, :host => host)
        end
      end
    end
  end
end
