class Memory < ApplicationRecord
  belongs_to :user

  after_commit :limit_memories, on: :create

  ## Deletes the oldest memory in exchange of the new memory
	def limit_memories
		Memory.all.order('id ASC').first.destroy if Memory.count > 10000
	end
end
