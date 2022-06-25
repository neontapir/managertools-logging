# frozen_string_literal: true

require './lib/commands/grade_update_command'
require './lib/commands/new_hire_command'

RSpec.describe GradeUpdateCommand do
  mal_folder = File.join %W[#{Settings.root} firefly malcolm-reynolds]
  new_hire = NewHireCommand.new

  subject(:grade_update) { described_class.new }

  before do
    expect { new_hire.command %w[firefly malcolm reynolds] }.to output(/malcolm-reynolds/).to_stdout
  end

  after do
    FileUtils.rm_r File.dirname(mal_folder)
  end

  let(:mal) { Employee.find 'mal' }

  def ensure_mal_is_a_captain(mal_file)
    grade_update.command %w[Captain mal]
    expect(File.readlines(mal_file.path)).to include(/^Grade level:: Captain\s*$/)
  end

  it 'adds a grade level if none is present' do
    mal_file = mal.file
    expect(File.readlines(mal_file.path)).to include(/^Grade level::\s*$/)

    ensure_mal_is_a_captain(mal_file)
  end

  it 'changes the grade level if one is present' do
    mal_file = mal.file
    text = File.read(mal_file.path)
    new_contents = text.gsub(/Grade level::.*/, 'Grade level:: Corporal')
    mal_file.replace_with(new_contents)
    expect(File.readlines(mal_file.path)).to include(/^Grade level:: Corporal\s*$/)

    ensure_mal_is_a_captain(mal_file)
  end

  it 'does not change the grade level if the same one is present' do
    mal_file = mal.file
    text = File.read(mal_file.path)
    new_contents = text.gsub(/Grade level::.*/, 'Grade level:: Captain')
    mal_file.replace_with(new_contents)
    expect(File.readlines(mal_file.path)).to include(/^Grade level:: Captain\s*$/)

    ensure_mal_is_a_captain(mal_file)
  end
end
