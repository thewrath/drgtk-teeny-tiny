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
			  		@current_level.save args
				end,
			:l => Proc.new do |args|
			  		@current_level.restore args
				end,
			:delete => Proc.new {|args| @block_type = -1},
			:zero => Proc.new {|args| @block_type = 0},
			:one => Proc.new {|args| @block_type = 1}
		}

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

	def handle_keys args
	  @keys.each do |input, action|
	    args.inputs.keyboard.keys.down.include?(input)
	    if args.inputs.keyboard.keys.down.include?(input) then
	      action.call(args)
	    end
	  end
	end

	def handle_mouse args
	  if args.inputs.mouse.button_left then
	    @current_level.each(Proc.new do |c, x, r, y|
	      if args.inputs.mouse.inside_rect?({x: BLOCK_SIZE*x, y: BLOCK_SIZE*y, w: BLOCK_SIZE, h: BLOCK_SIZE}) then
	        # Change block type
	        @current_level.set(x, y, @block_type)
	        update_render
	      end
	    end)
	  end
	end

	def update_render
		@current_level.invalid_draw = true
	end

end