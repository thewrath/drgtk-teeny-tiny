require 'app/level.rb'

def init args
  args.state.level = Level.new args

  # Interaction
  args.state.show_lines = true

  args.state.keys = {
    :s => Proc.new do |args|
      puts "Show lines toggle"
      args.state.show_lines = !args.state.show_lines
      args.state.level.invalid_draw = true
    end,
    :e => Proc.new do |args|
      args.state.level.save args
    end,
    :l => Proc.new do |args|
      args.state.level.restore args
    end,
    :delete => Proc.new {|args| set_block_type(args, nil)},
    :zero => Proc.new {|args| set_block_type(args, 0)},
    :one => Proc.new {|args| set_block_type(args, 1)}
  }

  args.state.block_type = 0
end

def tick args
  args.outputs.background_color = [0, 0, 0]

  args.state.debug_labels << "FPS : #{args.gtk.current_framerate.round}"
  args.state.debug_labels << "Show lines (S to toggle) : #{args.state.show_lines}"
  args.state.debug_labels << "Next block type : #{args.state.block_type}"
  args.state.debug_labels << "Export map (E)"

  init args if args.state.tick_count == 0
  
  handle_keys args
  handle_mouse args

  draw_debug_labels args
  args.state.level.draw args
end

def handle_keys args
  args.state.keys.each do |input, action|
    args.inputs.keyboard.keys.down.include?(input)
    if args.inputs.keyboard.keys.down.include?(input) then
      action.call(args)
    end
  end
end

def handle_mouse args
  if args.inputs.mouse.button_left then
    args.state.level.each(Proc.new do |c, x, r, y|
      if args.inputs.mouse.inside_rect?({x: BLOCK_SIZE*x, y: BLOCK_SIZE*y, w: BLOCK_SIZE, h: BLOCK_SIZE}) then
        # Change block type
        args.state.level.set(x, y, args.state.block_type)
        args.state.level.invalid_draw = true
      end
    end)
  end
end

def draw_debug_labels args
  args.state.debug_labels.each_with_index do |l, i|
    args.outputs.debug << [50, args.grid.top - (50 + (30*i)), l, 255, 255, 255].labels
  end

  args.state.debug_labels = []
end

def set_block_type(args, block_type)
  args.state.block_type = block_type
end