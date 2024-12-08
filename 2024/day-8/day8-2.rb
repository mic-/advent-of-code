# Advent of Code 2024 - Day 8: Resonant Collinearity, part 2
# Mic, 2024

def vec_add(a,b)
    return [a, b].transpose.map {|x| x.reduce(:+)}
end

def vec_sub(a,b)
    return [a, b].transpose.map {|x| x.reduce(:-)}
end

def vec_scale(a,s)
    return a.map { |x| x * s }
end

def is_within_bounds(p, bounds)
    return p[0] >= 0 && p[1] >= 0 && p[0] < bounds[0].size && p[1] < bounds.size
end

abort("Usage: ruby advent8-2.rb input.txt") if ARGV.size != 1
puzzle = File.readlines(ARGV[0], chomp: true)

antennas = Hash.new

puzzle.each_with_index do |line, row|
    line.each_char.with_index do |ch, column|
        if ch != '.'
            a = antennas.fetch(ch, [])
            antennas.store(ch, a.append([column, row]))
        end
    end
end

antinodes = Hash.new
antennas.each_key { |key|
    pos = antennas.fetch(key)
    for i in 0..pos.size-1
        for j in i+1..pos.size-1
            d = vec_sub(pos[i], pos[j])
            step = 0
            while step >= 0
                node1 = vec_add(pos[i], vec_scale(d, step))
                node2 = vec_sub(pos[j], vec_scale(d, step))
                step = is_within_bounds(node1, puzzle) || is_within_bounds(node2, puzzle) ? step+1 : -1
                antinodes.store(node1, 1) if is_within_bounds(node1, puzzle)
                antinodes.store(node2, 1) if is_within_bounds(node2, puzzle)
            end
        end
    end
}

puts "Number of unique antinode positions: " + antinodes.keys.size.to_s
