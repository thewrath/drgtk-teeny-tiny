module History

	def mut_target(target, method, params, reverse_method=nil, reverse_params=nil)
	 	if reverse_method && reverse_params then 
			push_reverse_action(target, reverse_method, reverse_params)
			push_action(target, method, params)
		elsif
			target.send(action, params)
		end

		update_render
	end
	
	def push_action(target, action, params)
		@history ||= []
		@history << {target: target, action: action, params: params}
		target.send(action, params)
	end

	def push_reverse_action(target, action, params)
		@reverse_history ||= []
		@reverse_history << {target: target, action: action, params: params}
	end

	def undo
		@undo_history ||= []
		# Todo : Call reverse action corresping to action and keep track of action that has been undo (to redo)
		reverse = @reverse_history.pop
		last = @history.pop
		if reverse && last then
			@undo_history << last
			reverse.target.send(reverse.action, reverse.params)
		end
		update_render
	end

	def redo
		
	end
end