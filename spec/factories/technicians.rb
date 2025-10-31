FactoryBot.define do
  factory :technician do
    association :user
    name { Faker::Name.name }
    specialty { Faker::Job.field }
    phone { Faker::PhoneNumber.phone_number }
    email { Faker::Internet.email }
  end
end
