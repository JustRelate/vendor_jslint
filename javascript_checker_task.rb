require 'rake/tasklib'
require File.dirname(__FILE__) + '/javascript_checker'

class JavascriptCheckerTask < Rake::TaskLib
  attr_accessor :file_list, :options

  def initialize(name = :javascript)
    @name = name
    self.file_list = FileList['**/*.js']
    self.options = {}
    yield self if block_given?
    define
  end

  private

  def define
    task @name do
      JavascriptChecker.check(file_list, options)
    end
  end
end
