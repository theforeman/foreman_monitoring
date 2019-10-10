# frozen_string_literal: true

FactoryBot.define do
  factory :monitoring_result do
    sequence(:service) { |n| "Service #{n}" }
    result { rand(0..3) }

    trait :ok do
      result { 0 }
    end

    trait :warning do
      result { 1 }
    end

    trait :critical do
      result { 2 }
    end

    trait :unknown do
      result { 3 }
    end

    trait :downtime do
      downtime { true }
    end

    trait :acknowledged do
      acknowledged { true }
    end
  end
end
