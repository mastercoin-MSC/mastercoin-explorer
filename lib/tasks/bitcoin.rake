namespace :bitcoin do
  task :relayer => :environment do 
    Rails.application.eager_load!

    EM.run do
      Bitcoin.network = :bitcoin
      MastercoinNode::Relayer.connect_random_from_dns([], 1, nil)
    end
  end
end

