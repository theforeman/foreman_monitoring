# frozen_string_literal: true

FactoryBot.modify do
  factory :smart_proxy do
    trait :monitoring do
      features { |sp| [sp.association(:feature, :monitoring)] }
    end
  end
end
