require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  include ApplicationHelper
  describe "#display_page_title" do
    context "引数が渡されている場合" do
      it "タブインデックスが指定したページタイトルを含む動的表示になっていること" do
        expect(display_page_title("test_title")).to eq "test_title | Votalog"
      end
    end

    context "引数がnilの場合" do
      it "タブインデックスにデフォルトタイトルが表示されていること" do
        expect(display_page_title(nil)).to eq "Votalog"
      end
    end

    context "引数が空白の場合" do
      it "タブインデックスにデフォルトタイトルが表示されていること" do
        expect(display_page_title(nil)).to eq "Votalog"
      end
    end
  end
end
