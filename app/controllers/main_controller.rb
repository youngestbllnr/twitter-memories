class MainController < ApplicationController
	before_action :authenticate_user!, except: [:index, :terms, :privacy]
	before_action :twitter_client, only: [:dashboard, :share]
	before_action :set_ads, only: [:index, :dashboard]

  ## Landing Page
	def index
    @user_count = UserTracker.find_by(context: 'count').data
	end

	## Dashboard
	def dashboard
		@tweets = []
		@memories = []

		# Retrieve saved memories
		lookup_saved_memories

		# Get memories from twitter api
		if lookup_memories?
			lookup_tweets
			filter_memories
		end

		# Rearrange and limit memories displayed on dashboard
		@memories = @memories.reverse.take(12)
	end

	## Shares a memory to twitter (parameters :url - of tweet/memory)
	def share
		url = params[:url]
		id = url.split("status/")[1]
		memory = @client.status(id)

		# Set text template for sharing
		if within_year?(memory)
			months_ago = months_ago(memory)
			text = share_text("month", months_ago)
		else
			years_ago = years_ago(memory)
			text = share_text("year", years_ago)
		end

		redirect_to share_link(text, url)
	end

	## Enables automated tweets
	def enable
		@user.update_attribute(:automated, true)

		flash[:notice] = "Automated #OnThisDay tweets has been enabed."
		redirect_to dashboard_path
	end

	## Disables automated tweets
	def disable
		@user.update_attribute(:automated, false)

		flash[:notice] = "Automated #OnThisDay tweets has been disabed."
		redirect_to dashboard_path
	end
end