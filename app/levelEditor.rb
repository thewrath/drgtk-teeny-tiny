require 'app/editor.rb'

class LevelEditor
	include History

	attr_accessor :current_level, :block_type

	def initialize level
		@current_level = level

		# Interaction
		@show_lines = true

		@keys = {
			:s => Proc.new do |args|
		  		@show_lines = !@show_lines
		  		update_render
			end,
			:e => Proc.new do |args|
		  		mut_target(@current_level, "save", {args: args})
			end,
			:l => Proc.new do |args|
		  		mut_target(@current_level, "restore", {args: args})
			end,
			:d => Proc.new do |args| 
				mut_target(@current_level, "reset", {args: args})
			end,
			:z => Proc.new do |args|
				undo
			end,
			:delete => Proc.new {|args| @block_type = -1},
			:zero => Proc.new {|args| @block_type = 0},
			:one => Proc.new {|args| @block_type = 1}
		}

		@keys_state = @keys.clone.transform_values! {|v| :up}

		@block_type = 0

		update_render
	end

	def tick args
		args.state.debug_labels << "Show lines (S to toggle) : #{@show_lines}"
		args.state.debug_labels << "Next block type : #{@block_type}"

		handle_keys args
		handle_mouse args
		@current_level.draw(@show_lines, args)
	end

	def update_render
		@current_level.invalid_draw = true
	end

	def handle_keys args
	  @keys.each do |input, action|
	    args.inputs.keyboard.keys.down.include?(input)
	    if args.inputs.keyboard.keys.down.include?(input) && @keys_state[input] != :down then
	      action.call(args)
	      @keys_state[input] = :down
	    elsif args.inputs.keyboard.keys.up.include?(input) then
	      @keys_state[input] = :up
	    end
	  end
	end

	def handle_mouse args
		# Todo : prevent mouse from multiple click on same block
	  if args.inputs.mouse.button_left then
	    @current_level.each_block(Proc.new do |c, x, r, y|
	      if args.inputs.mouse.inside_rect?({x: BLOCK_SIZE*x, y: BLOCK_SIZE*y, w: BLOCK_SIZE, h: BLOCK_SIZE}) then
	        # Change block type
	        # Todo : find previous block type
	        mut_target(@current_level,
	         "set",
        	 {x: x, y: y, block_type: @block_type},
	         "set",
	         {x: x, y: y, block_type: nil}
            )
	      end
	    end)
	  end
	end
end