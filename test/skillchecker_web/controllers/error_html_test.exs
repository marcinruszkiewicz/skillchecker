defmodule SkillcheckerWeb.ErrorHTMLTest do
  use SkillcheckerWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(SkillcheckerWeb.ErrorHTML, "404", "html", []) =~ "Record Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(SkillcheckerWeb.ErrorHTML, "500", "html", []) =~ "Something went wrong"
  end

  test "renders 500.html for any other errors" do
    assert render_to_string(SkillcheckerWeb.ErrorHTML, "403", "html", []) =~ "Something went wrong"
  end
end
