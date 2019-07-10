#!/usr/bin/env ruby
# frozen_string_literal: true

require 'pry'
require 'pry-remote'
require 'pry-nav'

require_relative './lib/manager_tools_cli'

module ManagerTools
  class Runner
    # Allow everything fun to be injected from the outside while defaulting to normal implementations.
    def initialize(argv, stdin = STDIN, stdout = STDOUT, stderr = STDERR, kernel = Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel
    end

    def execute!
      exit_code = begin
        # Thor accesses these streams directly rather than letting them be injected, so we replace them...
        $stderr = @stderr
        $stdin = @stdin
        $stdout = @stdout

        # Run our normal Thor app the way we know and love.
        # binding.pry
        ManagerTools::CLI.start(@argv)

        # Thor::Base#start does not have a return value, assume success if no exception is raised.
        0
      rescue StandardError => e
        # The ruby interpreter would pipe this to STDERR and exit 1 in the case of an unhandled exception
        b = e.backtrace
        @stderr.puts("#{b.shift}: #{e.message} (#{e.class})")
        @stderr.puts(b.map{|s| "\tfrom #{s}"}.join("\n"))
        1
      rescue SystemExit => e
        e.status
      ensure
        # Reset any singletons or other housekeeping...
        # ...then we put the streams back.
        $stderr = STDERR
        $stdin = STDIN
        $stdout = STDOUT
      end

      # Proxy our exit code back to the injected kernel.
      @kernel.exit(exit_code)
    end
  end
end

ManagerTools::Runner.new(ARGV.dup).execute! if $PROGRAM_NAME == __FILE__