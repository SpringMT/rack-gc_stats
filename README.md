# Rack::GCStats [![Build Status](https://travis-ci.org/SpringMT/rack-gc_stats.svg?branch=master)](https://travis-ci.org/SpringMT/rack-gc_stats)

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/rack/gc_stat`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-gc_stats'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-gc_stats

## Usage

### Rackup files

```
# In config.ru
use Rack::GCStats, scoreboard_path: './tmp', enabled: true
```

### Get GC Stats under Ruby 2.3.1

Launch the rack server using 8080 port with Rack::GCStats.

Then access gc_stats path(default: /gc_stats).

When add `?json` query parameter, return JSON formatted response.

```
% curl -s localhost:8080/gc_stats?json | jq .
{
  "stats": [
    {
      "count": 30,
      "heap_allocated_pages": 181,
      "heap_sorted_length": 181,
      "heap_allocatable_pages": 0,
      "heap_available_slots": 73775,
      "heap_live_slots": 73031,
      "heap_free_slots": 744,
      "heap_final_slots": 0,
      "heap_marked_slots": 42416,
      "heap_eden_pages": 181,
      "heap_tomb_pages": 0,
      "total_allocated_pages": 181,
      "total_freed_pages": 0,
      "total_allocated_objects": 332752,
      "total_freed_objects": 259721,
      "malloc_increase_bytes": 223552,
      "malloc_increase_bytes_limit": 16777216,
      "minor_gc_count": 26,
      "major_gc_count": 4,
      "remembered_wb_unprotected_objects": 328,
      "remembered_wb_unprotected_objects_limit": 584,
      "old_objects": 39244,
      "old_objects_limit": 74280,
      "oldmalloc_increase_bytes": 224000,
      "oldmalloc_increase_bytes_limit": 16777216,
      "pid": 40389,
      "ppid": 40376,
      "time": 1506525908,
      "uptime": 1506525815
    }
  ]
}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-gc_stat. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rack::GcStat project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rack-gc_stat/blob/master/CODE_OF_CONDUCT.md).
