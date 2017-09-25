require 'parallel'
require 'net/http'
require 'json'

$proc_num = 5
$execute_num = 10

Parallel.map([1,2,3,4,5,6], :in_processes => $proc_num) do |letter|
  $execute_num.times do
    http = Net::HTTP.new('localhost', 8080)
    req = Net::HTTP::Get.new('/foo')
    http.request(req)
    req = Net::HTTP::Get.new('/gc_stats?json')
    res = http.request(req)
    gc = JSON.parse(res.body)
    gc['stats'].each do |stat|
      puts "pid:#{stat['pid']}\tminor_gc_count:#{stat['minor_gc_count']}\tmalloc_increase_bytes:#{stat['malloc_increase_bytes']}"
    end
  end
end
