/*
 * Advent of Code 2023 - Day 5: If You Give A Seed A Fertilizer, part 2
 * /Mic, 2023
 *
 * Naive approach which considers all possible seeds.
 *
 * Requires a c++20-capable compiler.
 */

#include <fstream>
#include <future>
#include <iostream>
#include <sstream>
#include <string>
#include <unordered_map>
#include <vector>

struct Range {
    Range(const uint64_t start, const uint64_t length) :
        start_(start), length_(length)
    {}

    bool contains(const uint64_t value) const noexcept {
        return (value >= start_) && (value < start_ + length_);
    }

    uint64_t start_;
    uint64_t length_;
};

using Name = std::size_t;

struct Mapping {
    Mapping(const Name &source, const Name &destination) :
        source_(source), destination_(destination)
    {}

    Mapping() : Mapping(Name{}, Name{})
    {}

    uint64_t get_destination_id(const uint64_t source_id) const {
        auto it = std::find_if(source_ranges_.cbegin(), source_ranges_.cend(), [&] (auto &r) { return r.contains(source_id); });
        if (it != source_ranges_.cend()) {
            const auto index = std::distance(source_ranges_.cbegin(), it);
            return destination_ranges_[index].start_ + source_id - it->start_;
        }
        return source_id;
    }

    std::size_t source_;
    std::size_t destination_;
    std::vector<Range> source_ranges_;
    std::vector<Range> destination_ranges_;
};

using Mappings = std::unordered_map<std::size_t, Mapping>;


std::vector<std::string> split(const std::string &str, const std::string_view &delimiter) {
    const auto delim_size = delimiter.size();
    std::vector<std::string> tokens;
    std::string::size_type pos = 0;
    while (pos != std::string::npos) {
        const auto delim_pos = str.find(delimiter, pos);
        const auto count = (delim_pos != std::string::npos) ? (delim_pos - pos) : delim_pos;
        const auto token = str.substr(pos, count);
        if (! token.empty()) tokens.push_back(token);
        pos = (delim_pos != std::string::npos) ? (delim_pos + delim_size) : delim_pos;
    }
    return tokens;
}

uint64_t get(const Name what, Name from_name, uint64_t from_id, const Mappings &mappings) {
    while (from_name != what) {
        const auto &mapping = mappings.at(from_name);
        const auto destination_id = mapping.get_destination_id(from_id);
        if (mapping.destination_ == what) {
            return destination_id;
        }
        from_name = mapping.destination_;
        from_id = destination_id;
    }
    throw std::out_of_range("from == what");
}

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cerr << "Error: no input file specified." << std::endl;
        return 1;
    }

    std::ifstream input_file;
    input_file.open(argv[1]);

    if(! input_file.is_open()) {
        std::cerr << "Error: Unable to open file " << argv[1] << std::endl;
        return 1;
    }

    std::vector<Range> seeds;
    Mappings mappings;
    Mapping current_mapping;
    std::hash<std::string> hasher;
    std::string line;
    while(getline(input_file, line)) {
        if (line.starts_with("seeds:")) {
            const auto numbers = split(split(line, ":").back(), " ");
            for (int i = 0; i < numbers.size(); i += 2) {
                seeds.emplace_back(std::stoul(numbers[i]), std::stoul(numbers[i+1]));
            }
        } else if (line.ends_with("map:")) {
            mappings[current_mapping.source_] = current_mapping;
            const auto source_and_dest = split(split(line, " ").front(), "-to-");
            current_mapping = Mapping(hasher(source_and_dest.front()), hasher(source_and_dest.back()));
        } else {
            const auto numbers = split(line, " ");
            if (numbers.size() == 3) {
                const auto length = std::stoul(numbers[2]);
                current_mapping.destination_ranges_.emplace_back(std::stoul(numbers[0]), length);
                current_mapping.source_ranges_.emplace_back(std::stoul(numbers[1]), length);
            }
        }
    }
    mappings[current_mapping.source_] = current_mapping;

    input_file.close();

    std::cout << "Processing on " << seeds.size() << " threads..." << std::endl;

    std::vector<std::future<uint64_t>> deferred_locations;
    const auto seed_name = hasher("seed");
    const auto location_name = hasher("location");
    for (const auto &seed_range : seeds) {
        deferred_locations.push_back(std::async(std::launch::async, [&] () {
            std::uint64_t lowest_location = std::numeric_limits<uint64_t>::max();
            for (auto i = seed_range.start_; i < seed_range.start_ + seed_range.length_; i++) {
                const auto location = get(location_name, seed_name, i, mappings);
                if (location < lowest_location) lowest_location = location;
            }
            return lowest_location;
        }));
    }

    std::uint64_t lowest_location = std::numeric_limits<uint64_t>::max();
    for (auto &deferred : deferred_locations) {
        const auto location = deferred.get();
        if (location < lowest_location) lowest_location = location;
    }

    std::cout << "Lowest location is " << lowest_location << std::endl;

    return 0;
}