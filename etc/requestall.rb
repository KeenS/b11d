#!/usr/bin/env ruby

require 'json'
require 'net/http'

class Thread
  class Pool
    def initialize(size, &session)
      @size    = size
      @queue   = Queue.new
      @threads = []
      session.call(self)
    ensure
      shutdown
    end

    def run(&job)
      @queue.push(job)
      @threads << create_thread if @threads.size < @size
    end

    protected
    def shutdown
      until @queue.num_waiting == @threads.size
        sleep(0.01)
      end
      @threads.each { |th| th.kill }
    end

    protected
    def create_thread
      Thread.start(@queue) {|q|
        loop { job = q.pop; job.call }
      }
    end
  end
end

module Enumerable
  def concurrent_each(n)
    Thread::Pool.new(n) {|pool|
      self.each {|x|
        pool.run { yield x } 
      }
    }
  end
end


http = Net::HTTP.new('localhost', 3000)

JSON::Parser.new((File.read("../resources/generatedTrainBidRequests.json"))).parse.concurrent_each(3) do |e|
  Thread.new do
    req = Net::HTTP::Post.new('/api/rtb/1.0.0/bid')
    req.body =  e["body"].to_json
    req["Content-Type"] = "application/json"
    res = http.request(req)
    print res.body
  end

end
