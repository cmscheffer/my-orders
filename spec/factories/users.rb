FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :user }

    trait :admin do
      role { :admin }
    end

    trait :with_service_orders do
      transient do
        service_orders_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:service_order, evaluator.service_orders_count, user: user)
      end
    end
  end
end
