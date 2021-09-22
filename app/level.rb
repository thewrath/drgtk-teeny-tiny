BLOCK_SIZE = 50

class Level
	attr_accessor :render_target, :invalid_draw

	def initialize(args)
		reset args
	  	@render_target = :grid
	end

	def each action
		@map.each_with_index do |r, y|
        	r.each_with_index do |c, x|
          		action.call(c, x, r, y)
        	end
      	end
	end

	def draw (show_lines, args)
	  if @invalid_draw then
	    each(Proc.new do |c, x, r, y|
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

	def set(x, y, type)
		@map[y][x] = type
	end

	def get_block_color c
	  [
	    {r: 255, g: 0, b: 0},
	    {r: 0, g: 255, b: 0},
	  ][c]
	end

	def save args
		args.gtk.serialize_state('save/last.txt', {map: @map})
	end

	def restore args
		state = args.gtk.deserialize_state 'save/last.txt'
		@map = state[:map]
		@invalid_draw = true
	end

	def reset args
		@map = Array.new(args.grid.top/BLOCK_SIZE) { |i| Array.new(args.grid.right/BLOCK_SIZE, -1) }
		@invalid_draw = true
	end
end
