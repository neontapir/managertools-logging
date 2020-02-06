# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require './lib/log_file'
require './lib/entries/observation_entry'
require './lib/settings'

RSpec.describe LogFile do
  avengers_folder = File.join(Settings.root, 'avengers')

  shared_examples 'entry insertion' do |item, result|
    it 'inserts the entry correctly' do
      subject.insert item
      expect(File.readlines(subject.path)).to eq result
    end
  end

  context 'with an employee (isolated examples)' do
    let (:hulk) { Employee.new(team: 'Avengers', first: 'Bruce', last: 'Banner') }
    subject(:hulk_file) { hulk.file }

    hulk_folder = File.join avengers_folder, 'bruce-banner'

    before do
      FileUtils.mkdir_p hulk_folder
    end

    after do
      FileUtils.rm_r File.dirname(hulk_folder)
    end

    it_behaves_like 'entry insertion', nil, %W[\n \n]
    it_behaves_like 'entry insertion', '', %W[\n \n]
    it_behaves_like 'entry insertion', 'foo', %W[\n foo\n]

    observation = ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Green')
    expected = ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Green\n"]
    it_behaves_like 'entry insertion', observation, expected

    it 'implements equality', :aggregate_failures do
      expect(hulk_file).to eq Employee.new(team: 'Avengers', first: 'Bruce', last: 'Banner').file
      expect(hulk_file).not_to eq Employee.new(team: 'Defenders', first: 'Bruce', last: 'Banner').file
    end
  end

  context 'with an employee (accumulating examples)', order: :defined do
    subject(:thor_file) do
      thor = Employee.new(team: 'Avengers', first: 'Thor', last: 'Odinson')
      thor.file
    end

    thor_folder = File.join avengers_folder, 'thor-odinson'

    before :context do
      FileUtils.mkdir_p thor_folder
    end

    after :context do
      FileUtils.rm_r File.dirname(thor_folder)
    end

    it 'knows the file path' do
      expect(thor_file.path).to eq File.join(thor_folder, Settings.log_filename)
    end

    # creates a new file if none exists
    it_behaves_like 'entry insertion', 'foobar', %W[\n foobar\n]

    # appends an entry if file is not empty
    it_behaves_like 'entry insertion', 'baz', %W[\n foobar\n \n baz\n]

    # does not add an extra leading carriage return if one provided
    it_behaves_like 'entry insertion', "\nqux", %W[\n foobar\n \n baz\n \n qux\n]
  end

  context 'when adding diary entries with date specified' do
    subject(:she_hulk_file) do
      she_hulk = Employee.new(team: 'Avengers', first: 'Jennifer', last: 'Walters')
      she_hulk.file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      she_hulk.file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      she_hulk.file
    end

    she_hulk_folder = File.join avengers_folder, 'jennifer-walters'

    before do
      FileUtils.mkdir_p she_hulk_folder
    end

    after do
      FileUtils.rm_r File.dirname(she_hulk_folder)
    end

    it 'appends multiple observations correctly' do
      expected = <<~EXPECTED

        === Observation (February  3, 2001,  4:05 AM)
        Content::
          Observation A

        === Observation (February  4, 2001,  5:06 AM)
        Content::
          Observation B
      EXPECTED
      expect(File.readlines(she_hulk_file.path).map(&:chomp)).to eq expected.split("\n")
    end

    it 'gets lines containing a date correctly' do
      expect(she_hulk_file.get_header_locations).to eq(
        Time.new(2001, 2, 3, 4, 5, 0) => 1,
        Time.new(2001, 2, 4, 5, 6, 0) => 5,
      )
    end
  end

  context 'when adding undated diary entries' do
    subject(:hawkeye_file) do
      hawkeye = Employee.new(team: 'Avengers', first: 'Clinton', last: 'Barton')
      file = hawkeye.file
      file.insert "\n=== Background Info\n"
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file
    end

    hawkeye_folder = File.join avengers_folder, 'clinton-barton'

    before :context do
      FileUtils.mkdir_p hawkeye_folder
    end

    after :context do
      FileUtils.rm_r File.dirname(hawkeye_folder)
    end

    it 'gets undated and dated entry headers correctly' do
      lines = File.readlines(hawkeye_file.path)
      expect(hawkeye_file.get_header_locations(lines)).to eq(
        Time.at(0) => 1,
        Time.new(2001, 2, 3, 4, 5, 0) => 3,
      )
    end
  end

  context 'when adding a new entry dated before earliest dated entry in file', order: :defined do
    subject(:captain_america_file) do
      captain_america = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      file = captain_america.file
      file.insert "\n=== Background Info\n"
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      file
    end

    let(:new_entry) { ObservationEntry.new(datetime: Time.new(1999, 1, 1, 0, 0, 0).to_s, content: 'Observation C') }

    captain_america_folder = File.join avengers_folder, 'steve-rogers'

    before do
      FileUtils.mkdir_p captain_america_folder
    end

    after do
      FileUtils.rm_r File.dirname(captain_america_folder)
    end

    it 'calculates the insertion position correctly' do
      before, after = captain_america_file.divide_file(new_entry)
      expect(before).to eq ["\n", "=== Background Info\n"]
      after_expected = <<~EXPECTED

        === Observation (February  3, 2001,  4:05 AM)
        Content::
          Observation A

        === Observation (February  4, 2001,  5:06 AM)
        Content::
          Observation B

      EXPECTED
      expect(after.map(&:chomp)).to eq after_expected.split("\n")
    end

    it 'inserts the new entry after the undated entries and before the earliest dated entry' do
      captain_america_file.make_backup
      before, after = captain_america_file.divide_file(new_entry)
      captain_america_file.write_entry_to(before, new_entry, after)
      expected = <<~EXPECTED

        === Background Info

        === Observation (January  1, 1999, 12:00 AM)
        Content::
          Observation C

        === Observation (February  3, 2001,  4:05 AM)
        Content::
          Observation A

        === Observation (February  4, 2001,  5:06 AM)
        Content::
          Observation B
      EXPECTED
      expect(File.readlines(captain_america_file.path).map(&:chomp)).to eq expected.split("\n")
      FileUtils.move(captain_america_file.backup, captain_america_file.path)
    end
  end

  context 'when adding a new entry dated between earliest and latest in file', order: :defined do
    subject(:black_widow_file) do
      black_widow = Employee.new(team: 'Avengers', first: 'Natasha', last: 'Romanoff')
      file = black_widow.file
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      file
    end

    let(:new_entry) { ObservationEntry.new(datetime: Time.new(2001, 2, 4, 0, 0).to_s, content: 'Observation C') }

    black_widow_folder = File.join avengers_folder, 'natasha-romanoff'

    before do
      FileUtils.mkdir_p black_widow_folder
    end

    after do
      FileUtils.rm_r File.dirname(black_widow_folder)
    end

    it 'calculates the insertion position correctly' do
      expected_before = ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Observation A\n"]
      expected_after = ["\n", "=== Observation (February  4, 2001,  5:06 AM)\n", "Content::\n", "  Observation B\n"]
      before, after = black_widow_file.divide_file(new_entry)
      expect(before).to eq expected_before
      expect(after).to eq expected_after
    end

    it 'inserts entry in correct place to preserve chronological order' do
      black_widow_file.make_backup
      before, after = black_widow_file.divide_file(new_entry)
      black_widow_file.write_entry_to(before, new_entry, after)
      expected = <<~EXPECTED

        === Observation (February  3, 2001,  4:05 AM)
        Content::
          Observation A

        === Observation (February  4, 2001, 12:00 AM)
        Content::
          Observation C

        === Observation (February  4, 2001,  5:06 AM)
        Content::
          Observation B
      EXPECTED
      expect(File.readlines(black_widow_file.path).map(&:chomp)).to eq expected.split("\n")
      FileUtils.move(black_widow_file.backup, black_widow_file.path)
    end
  end

  context 'when adding a new entry dated after latest in file', order: :defined do
    subject(:wasp_file) do
      wasp = Employee.new(team: 'Avengers', first: 'Janet', last: 'Van Dyne')
      file = wasp.file
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file.insert ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      file
    end

    let(:new_entry) { ObservationEntry.new(datetime: Time.new(2018, 1, 1, 0, 0).to_s, content: 'Observation C') }

    wasp_folder = File.join avengers_folder, 'janet-vandyne'

    before do
      FileUtils.mkdir_p wasp_folder
    end

    after do
      FileUtils.rm_r File.dirname(wasp_folder)
    end

    it 'calculates the insertion position correctly' do
      lines = File.readlines(wasp_file.path)
      before, after = wasp_file.divide_file(new_entry)
      expect(before).to eq lines
      expect(after).to eq []
    end

    it 'new entry is appended to the end' do
      wasp_file.make_backup
      before, after = wasp_file.divide_file(new_entry)
      wasp_file.write_entry_to(before, new_entry, after)
      expected = <<~EXPECTED

        === Observation (February  3, 2001,  4:05 AM)
        Content::
          Observation A

        === Observation (February  4, 2001,  5:06 AM)
        Content::
          Observation B

        === Observation (January  1, 2018, 12:00 AM)
        Content::
          Observation C
      EXPECTED
      expect(File.readlines(wasp_file.path).map(&:chomp)).to eq expected.split("\n")
      FileUtils.move(wasp_file.backup, wasp_file.path)
    end
  end
end
