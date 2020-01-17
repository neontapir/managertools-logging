# frozen_string_literal: true

require 'asciidoctor'
require 'sentimental'
require_relative '../employee'
require_relative '../settings'
Dir["#{__dir__}/entries/*_entry.rb"].each { |f| require_relative(f) }

# Create a sentiment report from a person's log file
class SentimentCommand

  # Create a sentiment report from a person's log file
  def command(arguments, options = nil)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    display_analysis(employee)
  end

  private

  def display_analysis(employee)
    content = extract_log_file_data(employee)

    analyzer = Sentimental.new
    analyzer.load_defaults

    sentiments = content
      .reject(&:nil?)
      .map{ |c| [c[0,50], analyzer.sentiment(c)] }
      .to_h

    pp sentiments

    analysis = content
      .reject(&:nil?)
      .map{ |c| [c[0,50], analyzer.score(c)] }
      .to_h

    pp analysis
  end

  def extract_log_file_data(employee)
    doc = Asciidoctor.load_file(employee.file.path)
    entries = DiaryEntry.descendants.map{|k| k.new.entry_banner}
    entries_regex = Regexp.union(entries)
    content =  doc.sections
      .filter{ |s| s.title =~ /#{entries_regex}/ }
      .flat_map{ |s| s.content }
      .map{ |c| c.tr("\n", ' ') }
      .map{ |c| c.gsub(/\<.+?\>/, '') }
  end
end