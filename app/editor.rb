module History
	def history
		@history ||= []
		@reverse_history ||= []
	end

	def push_state state
		@history << state
	end

	def undo
		state = @history.pop
		@reverse_history << state
		return state
	end

	def redo
		
	end
end