# Advents of Code 2023 - Day 2: Cube Conundrum, part 1
# Mic, 2023

class CubeSet
    def initialize(red, green, blue)
        @red = red
        @green = green
        @blue = blue
    end
    attr_accessor :red, :green, :blue
end

class Bag < CubeSet
    def initialize(red_string, green_string, blue_string)
        super(Integer(red_string), Integer(green_string), Integer(blue_string))
    end

    def contains_at_least?(r, g, b)
        return @red >= r && @green >= g && @blue >= b
    end
end

class Game
    def initialize(game_string)
        game, cube_sets = game_string.split(":")
        @id = Integer(/Game ([0-9]+)/.match(game)[1])
        @cube_sets = []
        cube_sets.split(";").each { |cube_set|
            red = begin Integer(/([0-9]+) red/.match(cube_set)[1]) rescue 0 end
            green = begin Integer(/([0-9]+) green/.match(cube_set)[1]) rescue 0 end
            blue = begin Integer(/([0-9]+) blue/.match(cube_set)[1]) rescue 0 end
            @cube_sets << CubeSet.new(red, green, blue)
        }
    end
    attr_accessor :id

    def get_max(extractor)
        return @cube_sets.inject(0) { |max, it|
            val = extractor.call(it)
            val > max ? val : max
        }
    end

    def is_possible?(bag)
        return bag.contains_at_least?(
            get_max(lambda {|it| it.red}),
            get_max(lambda {|it| it.green}),
            get_max(lambda {|it| it.blue})
        )
    end
end

abort("Usage: ruby advent2-1.rb input.txt #red #green #blue") if ARGV.size != 4

bag = Bag.new(ARGV[1], ARGV[2], ARGV[3])

sum_of_possible_games = 0

begin
    File.foreach(ARGV[0]).with_index { |line, line_num|
        game = Game.new(line)
        sum_of_possible_games += game.is_possible?(bag) ? game.id : 0
    }
rescue => e
    abort("Unable to open " + ARGV[0] + ": " + e.to_s)
end

puts "The sum of possible game IDs: " + sum_of_possible_games.to_s