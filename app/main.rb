require 'app/level.rb'
require 'app/editor.rb'
require 'app/levelEditor.rb'

def init args
  args.state.editor = LevelEditor.new(Level.new(args))
end

def tick args
  args.outputs.background_color = [0, 0, 0]

  args.state.debug_labels << "FPS : #{args.gtk.current_framerate.round}"
  args.state.debug_labels << "Export map (E)"
  args.state.debug_labels << "Load map (L)"

  init args if args.state.tick_count == 0
  
  args.state.editor.tick args
  draw_debug_labels args
end

def draw_debug_labels args
  args.state.debug_labels.each_with_index do |l, i|
    args.outputs.debug << [50, args.grid.top - (50 + (30*i)), l, 255, 255, 255].labels
  end

  args.state.debug_labels = []
end