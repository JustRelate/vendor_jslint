require 'tempfile'
require 'active_support' # to_json

class JavascriptChecker

  PATH = File.dirname(__FILE__)

  JSLINT_DEFAULT_OPTIONS = {
      :bitwise => true,
      :browser => true,
      :eqeqeq => true,
      :immed => true,
      :newcap => true,
      :nomen => true,
      :plusplus => true,
      :regexp => true,
      :rhino => true,
      :undef => true,
      :white => true,
      :indent => false,
      :onevar => false,
      }

  def self.check(files, options = {})
    self.new(files).run(options)
  end

  def third_party(external)
    "#{PATH}/3rdParty/#{external}"
  end

  def initialize(files)
    @files = files
  end

  def run(options)
    failures = []

    with_options_file(options) do |config_file|
      print "Checking Javascript "

      @files.each do |file|
        scan = check(file, config_file)
        if scan.failed?
          failures << scan
          $stdout.print "F"
        else
          $stdout.print "."
        end
        $stdout.flush
      end
    end

    if failures.empty?
      puts "\nOK"
    else
      puts "\nFAILED"
      failures.each do |f|
        puts f.source + ":"
        puts f.messages
      end
      raise "Javascript is broken"
    end
  end

  private

  def check(file, config_file)
    call = []
    call << 'java'
    call << '-jar'
    call << third_party('env-js.jar')
    call << '-w'
    call << '-debug'
    call << '-f'
    call << third_party('fulljslint.js')
    call << "#{PATH}/rhino.js"
    call << config_file
    call << file
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
    Result.new(ok, file, text)
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
    attr_reader :source, :messages

    def initialize(ok, source, messages)
      @ok = ok
      @source = source
      @messages = messages
    end

    def failed?
      !@ok
    end

  end

end
