# frozen_string_literal: true

require './lib/commands/new_hire_command'
require './lib/commands/record_diary_entry_command'
require './lib/commands/sentiment_command'

RSpec.describe SentimentCommand do
  context 'with an existing employee (Spider-Man)' do
    avengers_folder = File.join %W[#{Settings.root} avengers]

    before do
      Settings.with_mock_input "\nhere\nMet about goals\n\n\n" do
        expect { NewHireCommand.new.command(%w[Avengers Peter Parker]) }.to output.to_stdout
        RecordDiaryEntryCommand.new.command :one_on_one, ['parker']
      end
    end

    after do
      FileUtils.rm_r avengers_folder
    end

    it 'can generate the sentiment analysis' do
      expect { described_class.new.command('peter') }.to output(<<~MESSAGE
        positive (0.625):   Location  here  Notes  Met about goals  Actions#{' '}
      MESSAGE
                                                               ).to_stdout
    end
  end
end
