# frozen_string_literal: true

require 'asciidoctor'
require 'sentimental'
require_relative '../employee'
require_relative 'mt_command'
require_relative '../settings'
Dir["#{__dir__}/entries/*_entry.rb"].each { |f| require_relative(f) }

# Create a sentiment report from a person's log file
class SentimentCommand < MtCommand
  # a diary entry and its sentiment score
  SentimentData = Struct.new(:data, :sentiment, :score) do
    # display the data
    def to_s
      "#{sentiment} (#{score}): #{data}"
    end
  end

  # Create a sentiment report from a person's log file
  def command(arguments, _options = nil)
    person = Array(arguments).first
    raise 'missing person argument' unless person

    employee = Employee.get person
    display_analysis(employee)
  end

  private

  def display_analysis(employee)
    content = extract_log_file_data(employee).reject(&:nil?)

    analyzer = Sentimental.new
    analyzer.load_defaults
    analyzer.threshold = 0.25

    content = enrich_content(analyzer, content)

    content.each { |c| puts c }
  end

  def extract_log_file_data(employee)
    doc = Asciidoctor.load_file(employee.file.path)
    entry_banners = DiaryEntry
      .descendants
      .reject { |k| [PtoEntry].include? k }
      .map { |k| k.new.entry_banner }
    entries_regex = Regexp.union(entry_banners)

    doc.sections
      .filter { |s| s.title.match?(/#{entries_regex}/) }
      .flat_map(&:content)
      .map { |c| c.tr("\n", ' ').gsub(/\<.+?\>/, '').to_s[0, 50] }
  end

  def enrich_content(analyzer, content)
    content.map do |text|
      sentiment = analyzer.sentiment(text)
      next if sentiment == :neutral

      SentimentData.new(text, sentiment, analyzer.score(text).round(3))
    end
  end
end
