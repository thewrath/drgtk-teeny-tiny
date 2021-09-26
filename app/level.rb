BLOCK_SIZE = 50

class Level
	attr_accessor :render_target, :invalid_draw
	attr_reader :map

	def initialize(args)
		reset({args: args})
	  	@render_target = :grid_target
	end

	def each_block action
		@grid.each_with_index do |r, y|
        	r.each_with_index do |c, x|
          		action.call(c, x, r, y)
        	end
      	end
	end

	def draw (show_lines, args)
	  if @invalid_draw then
	    each_block(Proc.new do |c, x, r, y|
	        if c == -1 && show_lines then
	          args.render_target(@render_target).borders << {x: BLOCK_SIZE*x, y: BLOCK_SIZE*y, w: BLOCK_SIZE, h: BLOCK_SIZE, r: 255, g: 0, b: 0}
	        elsif c > -1 then
	          args.render_target(@render_target).solids << {x: BLOCK_SIZE*x, y: BLOCK_SIZE*y, w: BLOCK_SIZE, h: BLOCK_SIZE, }.merge(get_block_color(c))
	        end
	    end)

	    @invalid_draw = false
	  end

	  args.outputs.sprites << { x: 0,
	                            y: 0,
	                            w: args.grid.right,
	                            h: args.grid.top,
	                            path: @render_target,
	                            source_x: 0,
	                            source_y: 0,
	                            source_w: args.grid.right,
	                            source_h: args.grid.top }
	end

	def set params
		@grid[params[:y]][params[:x]] = params[:block_type]
	end

	def get_block_color c
	  [
	    {r: 255, g: 0, b: 0},
	    {r: 0, g: 255, b: 0},
	  ][c]
	end

	def save params
		params[:args].gtk.serialize_state('data/last.txt', {grid: @grid})
	end

	def restore params
		state = params[:args].gtk.deserialize_state 'data/last.txt'
		@grid = state[:grid]
	end

	def reset params
		@grid = Array.new(params[:args].grid.top/BLOCK_SIZE) { |i| Array.new(params[:args].grid.right/BLOCK_SIZE, -1) }
	end
end
