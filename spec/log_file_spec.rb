# frozen_string_literal: true

require './lib/log_file.rb'
require './lib/observation_entry.rb'

describe LogFile, order: :defined do
  context 'with an employee' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      LogFile.new(EmployeeFolder.new(tony))
    end

    it 'knows the file path' do
      expect(subject.path).to eq('data/avengers/tony-stark/log.adoc')
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

  context 'with diary entries' do
    before(:all) do
      FileUtils.mkdir_p('data/avengers/tony-stark')
    end

    after(:all) do
      FileUtils.rm_r('data/avengers')
    end

    subject do
      tony = Employee.new(team: 'Avengers', first: 'Tony', last: 'Stark')
      LogFile.new(EmployeeFolder.new(tony))
    end

    it 'appends multiple observations correctly' do
      subject.append ObservationEntry.new(datetime: Time.new(2001, 2, 3, 4, 5, 6).to_s, content: 'Observation A')
      subject.append ObservationEntry.new(datetime: Time.new(2001, 2, 4, 5, 6, 7).to_s, content: 'Observation B')
      expect(File.readlines(subject.path)).to eq ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n", 
        "Content::\n", "  Observation A\n", "\n", "=== Observation (February  4, 2001,  5:06 AM)\n", 
        "Content::\n", "  Observation B\n"]
    end

    it 'gets date lines correctly' do
      lines = File.readlines(subject.path)
      expect(subject.get_datelines(lines)).to eq({
        Time.new(2001, 2, 3, 4, 5, 0) => 1,
        Time.new(2001, 2, 4, 5, 6, 0) => 5
      })
    end

    context 'when entry is before first in file' do
      let(:new_entry) { ObservationEntry.new(datetime: Time.new(1999, 1, 1, 0, 0, 0).to_s, content: 'Observation C') }

      it 'calculates the position correctly' do
        lines = File.readlines(subject.path)
        before, after = subject.divide_file(new_entry)
        expect(before).to eq([])
        expect(after).to eq(lines)
      end

      it 'inserts entry correctly' do
        subject.make_backup
        before, after = subject.divide_file(new_entry)
        subject.write_entry_to(before, new_entry, after)
        expect(File.readlines(subject.path)).to eq ["\n", "=== Observation (January  1, 1999, 12:00 AM)\n", 
        "Content::\n", "  Observation C\n", "\n", "=== Observation (February  3, 2001,  4:05 AM)\n", 
        "Content::\n", "  Observation A\n", "\n", "=== Observation (February  4, 2001,  5:06 AM)\n", 
        "Content::\n", "  Observation B\n"]
        FileUtils.move(subject.backup, subject.path)
      end
    end

    context 'when entry is between first and last in file' do
      let(:new_entry) { ObservationEntry.new(datetime: Time.new(2001, 2, 4, 0, 0).to_s, content: 'Observation C') }

      it 'calculates the position correctly' do
        expected_before = ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n", "Content::\n", "  Observation A\n"]
        expected_after =  ["\n", "=== Observation (February  4, 2001,  5:06 AM)\n", "Content::\n", "  Observation B\n"]
        before, after = subject.divide_file(new_entry)
        expect(before).to eq(expected_before)
        expect(after).to eq(expected_after)
      end

      it 'inserts entry correctly' do
        subject.make_backup
        before, after = subject.divide_file(new_entry)
        subject.write_entry_to(before, new_entry, after)
        expect(File.readlines(subject.path)).to eq ["\n", "=== Observation (February  3, 2001,  4:05 AM)\n", 
        "Content::\n", "  Observation A\n", "\n", "=== Observation (February  4, 2001, 12:00 AM)\n", 
        "Content::\n", "  Observation C\n", "\n", "=== Observation (February  4, 2001,  5:06 AM)\n", 
        "Content::\n", "  Observation B\n"]
        FileUtils.move(subject.backup, subject.path)
      end
    end

    context 'when entry is after last in file' do
      let(:new_entry) { ObservationEntry.new(datetime: Time.new(2018, 1, 1, 0, 0).to_s, content: 'Observation C') }

      it 'calculates the position correctly' do
        lines = File.readlines(subject.path)
        before, after = subject.divide_file(new_entry)
        expect(before).to eq(lines)
        expect(after).to eq([])
      end

      it 'inserts entry correctly' do
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
end
