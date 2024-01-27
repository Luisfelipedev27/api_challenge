FactoryBot.define do
  factory :hostname do
    hostname { Faker::Internet.domain_name }
    dns_record
    association :dns_record, factory: :dns_record

    trait :with_dns_records do
      transient do
        dns_records_count { 5 }
      end

      after(:create) do |hostname, evaluator|
        create_list(:dns_record, evaluator.dns_records_count, hostnames: [hostname])
      end
    end
  end
end
