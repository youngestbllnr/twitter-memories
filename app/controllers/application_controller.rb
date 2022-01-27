class ApplicationController < ActionController::Base

  ## Words to be ignored when scanning memories
	BLACKLIST = [
		"#OnThisDay", 
		"automatically checked by", 
		"Today stats:", 
		"Ask me anything!"
	]

  ## Checks if tweet contains items on the blacklist
	def blacklisted?(tweet)
		BLACKLIST.each do |item|
			return true if tweet.text.include? item
		end
		return false
	end

  ## Verifies if the current user is logged in
  def authenticate_user!
		if session[:user_id].present? && User.find(session[:user_id]).present?
			@user = User.find(session[:user_id])
		else
			flash.now[:notice] = "Session expired."
			redirect_to root_path
		end
	end

  ## Creates an instance of the twitter client
	def twitter_client
	  @client = Twitter::REST::Client.new do |config|
	    config.consumer_key        = Rails.application.credentials.twitter[:key]
	    config.consumer_secret     = Rails.application.credentials.twitter[:secret]
	    config.access_token        = @user.token
		  config.access_token_secret = @user.secret
  	end
  end

  ## Returns whether system should look up memories
	def lookup_memories?
		@memories.count == 0 && cookies[:no_memories_today].nil? && cookies[:saved_memories].nil?
	end

	## Retrieves saved memories
  def lookup_saved_memories
  	# Retrive memories from database
  	@saved_memories = @user.memories
		@saved_memories = @saved_memories.where(created_at: Date.current.beginning_of_day..Date.current.end_of_day)

		# Push to memories
		@saved_memories.each do |memory|
			@memories.push(memory)
		end

		# Indicate whether saved memories are used
		if @saved_memories.count > 0
			cookies[:saved_memories] = {
				value: "--",
				expires: Date.current.end_of_day
			}
		else
			cookies.delete :saved_memories
		end
	end

  ## Retrieves tweets from twitter api
	def lookup_tweets
		@client.user_timeline(@user.name, {
			count: 200, 
			exclude_replies: true, 
			include_rts: false
		}).each do |tweet|
			@tweets.push(tweet)
		end

		lookup_more_tweets if @tweets.count > 0
	rescue
		@tweets = []
		flash.now[:danger] = "Our servers seem to be full at the moment, please check back later."
	end

	## Retrieves maximum tweets allowed by twitter api
	def lookup_more_tweets
		16.times do
	    max_id = @tweets.last.uri.to_s.split('status/')[1].to_i
	    @client.user_timeline(@user.name, {
	    	count: 200,
	    	exclude_replies: true,
	    	include_rts: false,
	    	max_id: max_id
	    }).each do |tweet|
	      unless @tweets.include? tweet
	        @tweets.push(tweet)
	      end
	    end
	  end
  rescue
		@tweets = []
		flash.now[:danger] = "Our servers seem to be full at the moment, please check back later."
	end

  ## Filters memories from tweets
	def filter_memories
		@tweets.each do |tweet|
			if memory?(tweet)
				unless within_year?(tweet) || blacklisted?(tweet)
		      @memories.push(tweet)
				end
			end
		end

		save_memories(@memories)

    memory_tracker = MemoryTracker.find_by(context: 'count')
    memory_tracker.update_attribute(:data, memory_tracker.data += @memories.count) if memory_tracker && @memories.count > 0

		cookies[:no_memories_today] = { value: "--", expires: Date.current.end_of_day } if no_memories?
	end

  ## Checks if there are no memories retrieved
	def no_memories?
		@memories.count == 0
	end

	## Saves a memory to database
	def save_memory(memory)
		Memory.create(
			user_id: @user.id,
			text: memory.text,
			uri: memory.uri.to_s,
			date: memory.created_at.to_s,
			status: "retrieved"
		)
	end

	## Saves multiple memories to database
	def save_memories(memories)
		memories.each do |memory|
			unless existing_memory?(memory)
				save_memory(memory)
			end
		end
	end

	## Checks if memory is on the database
	def existing_memory?(memory)
		Memory.where(uri: memory.uri.to_s).count > 0
	end

  ## Verifies if tweet is a memory
	def memory?(tweet)
		current_date = Date.current.strftime("%m-%d")
		tweet_date = (tweet.created_at + 8.hours).strftime("%m-%d")
    
		return current_date == tweet_date
	end

  ## Checks if memory was tweeted within the current year
  def within_year?(tweet)
		current_year = Date.current.strftime("%Y")
		tweet_year = (tweet.created_at + 8.hours).strftime("%Y")

		return current_year == tweet_year
	end

	## Returns how many months ago the tweet was posted
	def months_ago(tweet)
		current_month = Date.current.strftime("%-m").to_i
		tweet_month = (tweet.created_at + 8.hours).strftime("%-m").to_i

		return current_month - tweet_month
	end

	## Returns how many years ago the tweet was posted
	def years_ago(tweet)
		current_year = Date.current.strftime("%Y").to_i
		tweet_year = (tweet.created_at + 8.hours).strftime("%Y").to_i

		return current_year - tweet_year
	end

  ## Returns text template when sharing memories
	def share_text(unit, value)
		"%23OnThisDay%2C%20#{ value }%20#{ unit }(s)%20ago%E2%80%94twitter%20memories%20via%20throwback.cc"
	end
	
	## Redirects link to twitter sharer (with template)
	def share_link(text, url)
		"https://twitter.com/intent/tweet?text=#{ text }%0A%0A#{ url }"
	end

  ## Sets necessary variables when rendering ads
	def set_ads
		# Update to FALSE to hide advertisements
		@display_ads = true

		# Advertisement: Custom Format
		@custom_ad = """
		<div id=\"custom-ad\">
			<a href=\"https://www.parapol.ph?utm_source=twitter-memories&utm_medium=banner&utm_campaign=waitlist\" target=\"_blank\">
				<img src=\"/ads/parapol.png\" />
			</a>
		</div>
		""".html_safe
	end
end
