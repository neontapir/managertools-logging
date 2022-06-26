# frozen_string_literal: true

require './lib/diary'
Dir['./lib/entries/*_entry.rb'].sort.each { |x| require x }

RSpec.describe Diary do
  context 'when making diary entries' do
    after do
      FileUtils.rm_r File.join(Settings.root, 'avengers')
    end

    context 'with template' do
      subject(:diary_templated) do
        (Class.new do
          include Diary

          def template?
            true # non-interactive mode
          end
        end).new
      end

      mantis_folder = File.join %W[#{Settings.root} avengers mr-brandt]

      before do
        FileUtils.mkdir_p mantis_folder
      end

      it 'appends an entry to the correct file' do
        log = LogFile.new(Dir.new(mantis_folder)).path
        old_length = File.size?(log) ? File.size(log) : 0
        _ = diary_templated.record_to_file(:interview, 'mr-brandt')
        expect(File.size(log)).to be > old_length
      end
    end

    context 'with interaction', order: :defined do
      iron_man_folder = File.join %W[#{Settings.root} avengers tony-stark]
      subject(:diary) do
        (Class.new do
          include Diary

          def template?
            false # interactive mode
          end
        end).new
      end

      let(:test_entry) do
        Class.new(DiaryEntry) do
          def prompt(name)
            "Enter your test for #{name}:"
          end

          def elements
            [
              DiaryElement.new(:xyzzy),
              DiaryElement.new(:wumpus, 'Wumpus', default: 'I feel a draft'),
              DiaryElement.new(:zork, 'Zork', default: 'plover', prompt: nil),
            ]
          end

          def to_s
            render('Blah blah')
          end
        end
      end

      before do
        FileUtils.mkdir_p iron_man_folder

        stub_const('DiaryEntry::TestEntry', test_entry)

        # this spy setup prevents the prompt from echoing to STDOUT during tests
        allow($stdout).to receive(:puts).with('Enter your test for Tony Stark:')
      end

      it 'displays a prompt' do
        #allow($stdout).to receive(:puts).with('Enter your test for Tony Stark:')
        allow(Settings.console).to receive(:ask).and_return('anything')
        diary.record_to_file(:test, 'tony-stark')
        expect($stdout).to have_received(:puts).with('Enter your test for Tony Stark:')
      end

      it 'appends an entry' do
        log = LogFile.new(Dir.new(iron_man_folder)).path
        old_length = File.size?(log) ? File.size(log) : 0

        allow(Settings.console).to receive(:ask).and_return("Lorem ipsum dolor sit amet, ea sea integre aliquando cotidieque, est dicta dolores concludaturque ne, his in dolorem volutpat.\nPro in iudico deseruisse, vix feugait accommodare ut, ne iisque appetere delicatissimi nec.")
        diary.record_to_file(:test, 'tony-stark')
        expect(File.size(log)).to be > old_length
      end

      it 'gets an entry with user input' do
        #allow($stdout).to receive(:puts)
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /Xyzzy/ then 'anything'
          end
        end
        entry = diary.get_entry 'Test', 'Tony Stark'
        expect(entry.record).to include(xyzzy: 'anything')
      end

      it 'uses default values when getting an entry' do
        allow(Settings.console).to receive(:ask).and_return(nil)
        entry = diary.get_entry 'Test', 'Tony Stark'
        expect(entry.record).to include(wumpus: 'I feel a draft')
      end

      it 'overwrites default values with user input' do
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /Xyzzy/ then 'anything'
          when /Wumpus/ then 'AHA! You got the wumpus!'
          end
        end
        entry = diary.get_entry 'Test', 'Tony Stark'
        expect(entry.record).to include(wumpus: 'AHA! You got the wumpus!')
      end

      it 'inserts initial values into its record' do
        #allow($stdout).to receive(:puts)
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /Xyzzy/ then 'anything'
          end
        end
        entry = diary.get_entry 'Test', 'Tony Stark', oregon_trail: 'BANG'
        expect(entry.record).to include(xyzzy: 'anything')
        expect(entry.record).to include(oregon_trail: 'BANG')
      end

      it 'prioiritizes injected values over user input and default value' do
        allow(Settings.console).to receive(:ask) do |prompt|
          case prompt
          when /Zork/ then 'user input value'
          end
        end

        entry = diary.get_entry 'Test', 'Tony Stark', zork: 'The Great Underground Empire'

        expect(entry.record).not_to include(zork: 'plover'), 'failure: used default value'
        expect(entry.record).to include(zork: 'The Great Underground Empire')
      end
    end

    context 'with diary entries that disable prompting' do
      subject(:entry) { diary_no_prompt.get_entry('Test No Prompt', 'Luke Cage') }

      let(:diary_no_prompt) do
        (Class.new do
          include Diary

          def template?
            false # interactive mode
          end
        end).new
      end
      # Create a plain type of diary entry

      let(:test_no_prompt_entry) do
        Class.new(DiaryEntry) do
          def prompt(name)
            "Enter your test for #{name}:"
          end

          def elements
            [
              DiaryElement.new(:xyzzy, 'Xyzzy', default: 'adventure', prompt: nil),
              DiaryDateElement.new(:adventure_time, 'Adventure Time', default: Time.local(2000), prompt: nil),
            ]
          end

          def to_s
            render('Blah blah')
          end
        end
      end

      let(:luke_cage_folder) { File.join %W[#{Settings.root} avengers luke-cage] }

      before do
        FileUtils.mkdir_p luke_cage_folder
        stub_const('DiaryEntry::TestNoPromptEntry', test_no_prompt_entry)
        allow($stdout).to receive(:puts)
        allow(Settings.console).to receive(:ask)
      end

      # NOTE: This feature is useful for derived values, like 'duration' on PtoEntry.
      #   Other tests cover post-prompting data modification.
      it 'uses the default values instead of prompting for entry' do
        expect(Settings.console).not_to have_received(:ask)
      end

      it 'includes the default values' do
        expect(entry.record).to include(xyzzy: 'adventure')
        expect(entry.record[:adventure_time].strftime('%F')).to eq('2000-01-01')
      end
    end
  end
end
