module History

	def push_state state
		@history ||= []
		@history << state.clone
	end

	def undo
		@history ||= []
		@reverse_history ||= []
		state = @history.pop
		@reverse_history << state.clone if state != nil
		return state
	end

	def redo
		
	end
end