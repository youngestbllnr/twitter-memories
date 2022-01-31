namespace :twitter do
  desc "Tweets daily updates."
  task tweet_memories: :environment do
    # Loop through users (who enabled automated tweets)
    # Temporarily removed .where('created_at < ?', 1.day.ago)
  	User.all
        .where(automated: true)
        .order('id DESC')
        .each do |user|

      # Break if time limit has been exceeded
      break if Time.current.utc > (Time.current.utc.end_of_day - 15.minutes)

      # Initialize twitter client
  		client = Twitter::REST::Client.new do |config|
		    config.consumer_key        = Rails.application.credentials.twitter[:key]
		    config.consumer_secret     = Rails.application.credentials.twitter[:secret]
		    config.access_token        = user.token
			  config.access_token_secret = user.secret
  		end

      # Begin task
      begin
        # Initiate variables
        memories = []
        tweets = []
        stop_retrieval = false

        # Get tweets
        client.user_timeline(user.name, {count: 200, exclude_replies: true, include_rts: false}).each do |tweet|
          tweets.push(tweet)
        end

        # Get more tweets (up to 3200)
        if tweets.count > 0
          for i in 1..17 do
            unless stop_retrieval
              max_id = tweets.last.uri.to_s.split('status/')[1].to_i
              client.user_timeline(user.name, {count: 200, exclude_replies: true, include_rts: false, max_id: max_id}).each do |tweet|
                if tweets.include?(tweet)
                  stop_retrieval = true unless tweet == tweets.last
                else
                  tweets.push(tweet)
                end
              end
            end
          end
        end

        # Filter memories
        tweets.each do |tweet|
          if (tweet.created_at + 8.hours).strftime("%m-%d") == Date.current.strftime("%m-%d")
            unless (tweet.created_at + 8.hours).strftime("%Y") == Date.current.strftime("%Y")
              unless (tweet.text.include? "#OnThisDay") || (tweet.text.include? "automatically checked by") || (tweet.text.include? "Today stats:") || (tweet.text.include? ".com") || (tweet.text.include? "Ask me anything!") || (tweet.text.include? "#Throwback")
                memories.push(tweet)
              end
            end
          end
        end

        # Share a sample memory to twitter
        if memories.count > 0
          memory = memories.sample
          years_ago = Date.current.strftime("%Y").to_i - (memory.created_at + 8.hours).strftime("%Y").to_i

          client.update("💫 #Throwback from #{ years_ago } year(s) ago—twitter memories via throwback.cc", attachment_url: memory.uri)
        end
        
        # Logs
        puts "#{ Time.now } - #{ user.name } : #{ memories.count } memories / #{ tweets.count } tweets retrieved."
      rescue
        puts "#{ Time.now } - #{ user.name } : ACCESS DENIED!"
      end
  	end
  end
end