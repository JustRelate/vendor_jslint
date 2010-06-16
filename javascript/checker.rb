require 'tempfile'
require 'active_support' # to_json

module Javascript
  class Checker

    BASE = File.expand_path(File.dirname(__FILE__) + '/..')

    JSLINT_DEFAULT_OPTIONS = {
        # true
        :bitwise => true,
        :browser => true,
        :eqeqeq => true,
        :immed => true,
        :newcap => true,
        :nomen => true,
        :regexp => true,
        :rhino => true,
        :undef => true,
        # false
        :plusplus => false,
        :indent => false,
        :onevar => false,
        :white => false,
        }

    def self.check(files, options = {})
      self.new(files).run(options)
    end

    def third_party(external)
      "#{BASE}/3rdParty/#{external}"
    end

    def initialize(files)
      @files = files
    end

    def run(options)
      failures = []

      with_options_file(options) do |config_file|
        print "Checking Javascript "

        scan = check(@files, config_file)
        failures << scan if scan.failed?
      end

      if failures.empty?
        puts "\nOK"
      else
        puts "\nFAILED"
        failures.each do |f|
          puts f.messages
        end
        raise "Javascript is broken"
      end
    end

    private

    def check(files, config_file)
      call = []
      call << 'java'
      call << '-jar'
      call << third_party('env-js.jar')
      call << '-w'
      call << '-debug'
      call << '-f'
      call << third_party('fulljslint.js')
      call << "#{BASE}/rhino.js"
      call << config_file
      files.each do |f|
        call << f
      end
      failed = false
      call = call.map do |c|
          if c == ''
            '""'
          elsif c=~ /\s/
            "\"#{c}\""
          else
            c
          end
      end.join(' ')
      text = `#{call}`
      ok = text !~ /Lint at/
      Result.new(ok, text)
    end


    def with_options_file(options)
      options = JSLINT_DEFAULT_OPTIONS.merge(options || {})

      config = Tempfile.new('jslint')
      config << options.to_json
      config.close
      yield config.path
    ensure
      config.delete
    end

    class Result
      attr_reader :messages

      def initialize(ok, messages)
        @ok = ok
        @messages = messages
      end

      def failed?
        !@ok
      end

    end

  end

end
