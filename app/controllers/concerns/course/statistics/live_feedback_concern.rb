# frozen_string_literal: true
module Course::Statistics::LiveFeedbackConcern
  private

  def find_submitter_course_user(submission)
    submission.creator.course_users.find { |u| u.course_id == @assessment.course_id }
  end

  def find_live_feedback_course_user(live_feedback)
    live_feedback.creator.course_users.find { |u| u.course_id == @assessment.course_id }
  end

  def initialize_feedback_count
    Array.new(@question_order_hash.size, 0)
  end

  def find_user_assessment_live_feedback(submitter_course_user, assessment_live_feedbacks)
    assessment_live_feedbacks.select do |live_feedback|
      find_live_feedback_course_user(live_feedback) == submitter_course_user
    end
  end

  def update_feedback_count(feedback_count, user_assessment_live_feedback)
    user_assessment_live_feedback.each do |feedback|
      index = @ordered_questions.index(feedback.question_id)
      feedback.code.each do |code|
        unless code.comments.empty?
          feedback_count[index] += 1
          break
        end
      end
    end
  end

  def initialize_student_hash(students)
    students.to_h { |student| [student, nil] }
  end

  def fetch_hash_for_live_feedback_assessment(submissions, assessment_live_feedbacks)
    students = @all_students
    student_hash = initialize_student_hash(students)

    populate_hash(submissions, student_hash, assessment_live_feedbacks)
    student_hash
  end

  def populate_hash(submissions, student_hash, assessment_live_feedbacks)
    submissions.each do |submission|
      submitter_course_user = find_submitter_course_user(submission)
      next unless submitter_course_user&.student?

      feedback_count = initialize_feedback_count

      user_assessment_live_feedback = find_user_assessment_live_feedback(submitter_course_user,
                                                                         assessment_live_feedbacks)

      update_feedback_count(feedback_count, user_assessment_live_feedback)

      student_hash[submitter_course_user] = [submission, feedback_count]
    end
  end
end
