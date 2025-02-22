# frozen_string_literal: true
json.courses @courses do |course|
  json.id course.id
  json.name course.title
  json.canManageCourse can?(:manage, @course)
end
