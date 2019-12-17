# frozen_string_literal: true

require './lib/employee'
require './lib/employee_folder'
require './lib/log_file'
require './lib/entries/observation_entry'

RSpec.describe LogFile do
  avengers_folder = File.join(%W[#{Settings.root} avengers])

  before :all do
    FileUtils.mkdir_p avengers_folder
  end

  after :all do
    FileUtils.rm_r avengers_folder
  end

  context 'with an employee', order: :defined do
    thor_folder = File.join(avengers_folder, 'thor-odinson')

    before :all do
      FileUtils.mkdir_p thor_folder
    end

    after :all do
      FileUtils.rm_r thor_folder
    end

    subject do
      thor = Employee.new(team: 'Avengers', first: 'Thor', last: 'Odinson')
      LogFile.new(EmployeeFolder.new(thor))
    end

    it 'knows the file path' do
      expect(subject.path).to eq File.join(thor_folder, 'log.adoc')
    end

    it 'creates a new file if none exists' do
      subject.append 'foobar'
      expect(File.readlines(subject.path)).to eq %W[\n foobar\n]
    end

    it 'appends an entry' do
      subject.append 'baz'
      expect(File.readlines(subject.path)).to eq %W[\n foobar\n \n baz\n]
    end

    it 'does not add an extra leading carriage return if one provided' do
      subject.append "\nqux"
      expect(File.readlines(subject.path)).to eq %W[\n foobar\n \n baz\n \n qux\n]
    end
  end

  context 'with dated diary entries', order: :defined do
    iron_man_folder = File.join(avengers_folder, 'tony-stark')

    before :all do
      FileUtils.mkdir_p iron_man_folder
    end

    after :all do
      FileUtils.rm_r iron_man_folder
    end

    subject do
      iron_man = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      LogFile.new(EmployeeFolder.new(iron_man))
    end

    it 'appends multiple observations correctly' do
      subject.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      subject.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      expect(File.readlines(subject.path)).to eq ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n",
        "Content::\n", "  Observation A\n", "\n", "=== Observation (February  4, 2001,  5:06 AM)\n",
        "Content::\n", "  Observation B\n"]
    end

    it 'gets lines containing a date correctly' do
      lines = File.readlines(subject.path)
      expect(subject.get_header_locations(lines)).to eq(
        Time.new(2001, 2, 3, 4, 5, 0) => 1,
        Time.new(2001, 2, 4, 5, 6, 0) => 5
      )
    end
  end

  context 'with undated diary entries', order: :defined do
    hawkeye_folder = File.join(avengers_folder, 'clinton-barton')

    before :all do
      FileUtils.mkdir_p hawkeye_folder
    end

    after :all do
      FileUtils.rm_r hawkeye_folder
    end

    subject do
      hawkeye = Employee.new(team: 'Avengers', first: 'Clinton', last: 'Barton')
      file = LogFile.new(EmployeeFolder.new(hawkeye))
      file.append "\n=== Background Info\n"
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file
    end

    it 'gets undated and dated entry headers correctly' do
      lines = File.readlines(subject.path)
      expect(subject.get_header_locations(lines)).to eq(
        Time.at(0) => 1,
        Time.new(2001, 2, 3, 4, 5, 0) => 3
      )
    end
  end

  context 'when new entry is before earliest dated entry in file', order: :defined do
    captain_america_folder = File.join(avengers_folder, 'steve-rogers')

    before :each do
      FileUtils.mkdir_p captain_america_folder
    end

    after :each do
      FileUtils.rm_r captain_america_folder
    end

    subject do
      captain_america = Employee.new(team: 'Avengers', first: 'Steve', last: 'Rogers')
      file = LogFile.new(EmployeeFolder.new(captain_america))
      file.append "\n=== Background Info\n"
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      file
    end

    let(:new_entry) { ObservationEntry.new(datetime: Time.new(1999, 1, 1, 0, 0, 0).to_s, content: 'Observation C') }

    it 'calculates the insertion position correctly' do
      before, after = subject.divide_file(new_entry)
      expect(before).to eq ["\n", "=== Background Info\n"]
      expect(after).to eq ["\n",
        "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Observation A\n", "\n",
        "=== Observation (February  4, 2001,  5:06 AM)\n", "Content::\n", "  Observation B\n"
      ]
    end

    it 'inserts the new entry after the undated entries and before the earliest dated entry' do
      subject.make_backup
      before, after = subject.divide_file(new_entry)
      subject.write_entry_to(before, new_entry, after)
      expect(File.readlines(subject.path)).to eq ["\n",
        "=== Background Info\n", "\n",
        "=== Observation (January  1, 1999, 12:00 AM)\n", "Content::\n", "  Observation C\n", "\n",
        "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Observation A\n", "\n",
        "=== Observation (February  4, 2001,  5:06 AM)\n", "Content::\n", "  Observation B\n"]
      FileUtils.move(subject.backup, subject.path)
    end
  end

  context 'when new entry is between earliest and latest in file', order: :defined do
    black_widow_folder = File.join(avengers_folder, 'natasha-romanoff')

    before :each do
      FileUtils.mkdir_p black_widow_folder
    end

    after :each do
      FileUtils.rm_r black_widow_folder
    end

    subject do
      black_widow = Employee.new(team: 'Avengers', first: 'Natasha', last: 'Romanoff')
      file = LogFile.new(EmployeeFolder.new(black_widow))
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      file
    end

    let(:new_entry) { ObservationEntry.new(datetime: Time.new(2001, 2, 4, 0, 0).to_s, content: 'Observation C') }

    it 'calculates the insertion position correctly' do
      expected_before = ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Observation A\n"]
      expected_after =  ["\n", "=== Observation (February  4, 2001,  5:06 AM)\n", "Content::\n", "  Observation B\n"]
      before, after = subject.divide_file(new_entry)
      expect(before).to eq expected_before
      expect(after).to eq expected_after
    end

    it 'inserts entry in correct place to preserve chronological order' do
      subject.make_backup
      before, after = subject.divide_file(new_entry)
      subject.write_entry_to(before, new_entry, after)
      expect(File.readlines(subject.path)).to eq [
        "\n",
        "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Observation A\n", "\n",
        "=== Observation (February  4, 2001, 12:00 AM)\n", "Content::\n", "  Observation C\n", "\n",
        "=== Observation (February  4, 2001,  5:06 AM)\n", "Content::\n", "  Observation B\n"
      ]
      FileUtils.move(subject.backup, subject.path)
    end
  end

  context 'when new entry is after latest in file', order: :defined do
    wasp_folder = File.join(avengers_folder, 'janet-vandyne')

    before :each do
      FileUtils.mkdir_p wasp_folder
    end

    after :each do
      FileUtils.rm_r wasp_folder
    end

    subject do
      wasp = Employee.new(team: 'Avengers', first: 'Janet', last: 'Van Dyne')
      file = LogFile.new(EmployeeFolder.new(wasp))
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      file.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      file
    end

    let(:new_entry) { ObservationEntry.new(datetime: Time.new(2018, 1, 1, 0, 0).to_s, content: 'Observation C') }

    it 'calculates the insertion position correctly' do
      lines = File.readlines(subject.path)
      before, after = subject.divide_file(new_entry)
      expect(before).to eq lines
      expect(after).to eq []
    end

    it 'new entry is appended to the end' do
      subject.make_backup
      before, after = subject.divide_file(new_entry)
      subject.write_entry_to(before, new_entry, after)
      expect(File.readlines(subject.path)).to eq ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n",
      "Content::\n", "  Observation A\n", "\n", "=== Observation (February  4, 2001,  5:06 AM)\n",
      "Content::\n", "  Observation B\n", "\n", "=== Observation (January  1, 2018, 12:00 AM)\n",
      "Content::\n", "  Observation C\n"]
      FileUtils.move(subject.backup, subject.path)
    end
  end
end
