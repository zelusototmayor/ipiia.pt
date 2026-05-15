require "test_helper"

class CourseSessionsControllerTest < ActionDispatch::IntegrationTest
  test "login page is available at simple entrar path" do
    assert_equal "/entrar", new_course_session_path

    get new_course_session_path

    assert_response :success
    assert_select "h1", text: /Entrar no curso/
  end
end
