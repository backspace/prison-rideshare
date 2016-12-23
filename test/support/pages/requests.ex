defmodule PrisonRideshare.Pages.Requests do
  use PageObject

  visitable :visit, "/requests"

  clickable :create, "main > a"

  collection :requests, item_scope: "tbody tr" do
    text :start, "td:nth-child(2)"
    text :end, "td:nth-child(3)"

    text :name, "td:nth-child(4)"
    text :contact, "td:nth-child(6)"

    text :institution, "td:nth-child(9)"
  end
end