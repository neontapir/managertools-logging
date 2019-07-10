# frozen_string_literal: true

# Offers commodity validation functions
module FileContentsValidationHelper
	def verify_answers_propagated(answers, members)
    members.each do |member|
      member_file_contents = File.readlines(member.file.path)
      answers.each do |answer|
        expect(member_file_contents).to include(answer)
      end
    end
	end
end