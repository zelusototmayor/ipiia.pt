require "test_helper"

class CourseCatalogTest < ActiveSupport::TestCase
  test "fundamentals course has complete learning structure" do
    course = CourseCatalog.fundamentos

    assert_equal "fundamentos-ia-trabalho", course.slug
    assert_equal 6, course.modules.size
    assert_equal 18, course.lessons.size
    assert_equal 14, course.quiz.size
    assert course.lessons.all? { |lesson| lesson[:template].present? && lesson[:checkpoint].any? }
  end
end
