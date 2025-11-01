FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'P@ssw0rd123' }  # Senha forte que atende todos os requisitos
    password_confirmation { 'P@ssw0rd123' }
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
