require 'rails_helper'

RSpec.describe "Plants", type: :system do
  let(:user) { create(:user) }
  let(:plant) { create(:plant, user: user) }
  let(:another_user) { create(:user) }
  let!(:not_target_users_plant) { create(:plant, user: another_user) }

  before do
    login_as(user, scope: :user)
  end

  describe "新規株登録機能のテスト" do
    before do
      visit new_plant_path
    end

    context "新規株登録に成功した場合" do
      it "登録した株の詳細画面に遷移し、登録成功のフラッシュメッセージが表示されること" do
        new_plant = build(:plant, name: "testplant")
        fill_in "株名称", with: new_plant.name
        click_on "マイ多肉棚に追加"
        expect(page).to have_content "お世話ログ for #{new_plant.name}"
        expect(page).to have_content "#{new_plant.name}をマイ多肉棚に追加しました"
      end
    end

    context "新規株登録に失敗した場合" do
      it "新規株登録画面のまま、登録失敗のフラッシュメッセージが表示されること" do
        click_on "マイ多肉棚に追加"
        expect(current_path).to eq plants_path
        expect(page).to have_content "新しい株の登録に失敗しました"
      end
    end

    context "キャンセルボタンを押下した場合" do
      it "トップページに遷移すること" do
        click_on "キャンセル"
        expect(current_path).to eq root_path
      end
    end
  end

  describe "株詳細確認機能のテスト" do
    let(:plant_with_png_image) { create(:plant_with_png_image, user: user) }

    before do
      visit plant_path(plant_with_png_image)
    end

    it "ページ見出しに対象の株名称と株画像が表示されること" do
      expect(page).to have_content "お世話ログ for #{plant_with_png_image.name}"
      expect(page).to have_selector "img[alt=株イメージ画像]"
    end

    context "次回お世話予定を追加していない場合" do
      it "次回水やり・肥料/栄養剤散布・植替え予定日が空欄で表示されること" do
        within ".next-water-schedule" do
          expect(page).to have_content "----年--月--日"
        end
        within ".next-fertilizer-schedule" do
          expect(page).to have_content "----年--月--日"
        end
        within ".next-replant-schedule" do
          expect(page).to have_content "----年--月--日"
        end
      end
    end

    context "次回水やり予定日を追加した場合", js: true do
      it "次回水やり予定日のみが更新され、追加した予定の日付が表示されること" do
        click_on "お世話予定を追加"
        fill_in "次の水やり予定日", with: Date.tomorrow
        click_on "決定"
        within ".next-water-schedule" do
          expect(page).to have_content Date.tomorrow.strftime("%Y年%m月%d日")
        end
        within ".next-fertilizer-schedule" do
          expect(page).to have_content "----年--月--日"
        end
        within ".next-replant-schedule" do
          expect(page).to have_content "----年--月--日"
        end
      end
    end

    context "次回お世話予定追加モーダルでキャンセルボタンを押下した場合", js: true do
      it "モーダルウィンドウが消え、お世話予定が表示されること" do
        click_on "お世話予定を追加"
        click_on "キャンセル"
        within ".next-water-schedule" do
          expect(page).to have_content "----年--月--日"
        end
        within ".next-fertilizer-schedule" do
          expect(page).to have_content "----年--月--日"
        end
        within ".next-replant-schedule" do
          expect(page).to have_content "----年--月--日"
        end
      end
    end

    context "株情報編集ボタンを押下した場合" do
      it "株情報編集画面へ遷移すること" do
        click_on "株情報の編集"
        expect(current_path).to eq edit_plant_path(plant_with_png_image)
      end
    end

    context "この株を削除ボタンを押下した場合", js: true do
      it "confirmダイアログでOKすると、トップページに遷移しフラッシュメッセージが表示されること" do
        page.accept_confirm("#{plant_with_png_image.name}を削除してよろしいですか？") do
          click_on "この株を削除"
        end
        expect(current_path).to eq root_path
        expect(page).to have_content "#{plant_with_png_image.name}を削除しました"
      end
      it "confirmダイアログでキャンセルすると、株詳細確認画面のままになること" do
        page.dismiss_confirm("#{plant_with_png_image.name}を削除してよろしいですか？") do
          click_on "この株を削除"
        end
        expect(current_path).to eq plant_path(plant_with_png_image)
      end
    end

    context "新規ログを追加ボタンを押下した場合" do
      it "新規ログ作成画面に遷移すること" do
        click_on "新規ログを追加"
        expect(current_path).to eq new_log_path
      end
    end
  end

  describe "マイ多肉棚機能のテスト" do
    let!(:target_users_another_plant) { create(:plant, user: user) }

    before do
      visit plant_path(plant)
    end

    it "対象のユーザーが所有している株の名称のみが表示されていること" do
      within ".my-shelf" do
        expect(page).to have_content plant.name
        expect(page).not_to have_content not_target_users_plant.name
        expect(page).to have_content target_users_another_plant.name
      end
    end

    context "新しい株を追加ボタンを押下した場合" do
      it "新規株登録画面に遷移すること" do
        click_on "新しい株を追加する"
        expect(current_path).to eq new_plant_path
      end
    end

    context "ALLボタンを押下した場合" do
      it "お世話スケジュール画面に遷移すること" do
        click_on "ALL"
        expect(current_path).to eq root_path
      end
    end

    context "株名称ボタンを押下した場合" do
      it "株詳細確認画面に遷移すること" do
        click_on target_users_another_plant.name
        expect(current_path).to eq plant_path(target_users_another_plant)
      end
    end
  end

  describe "株編集機能のテスト" do
    before do
      visit edit_plant_path(plant)
    end

    it "必須項目の株名称がフォームに表示されていること" do
      expect(page).to have_field "株名称", with: plant.name
    end

    context "株情報を編集し、更新に成功した場合" do
      it "株詳細確認画面に遷移すること" do
        attach_file "株画像", "#{Rails.root}/spec/fixtures/sample_image.png"
        click_on "株情報を更新"
        expect(current_path).to eq plant_path(plant)
      end
    end

    context "株情報を編集したが、更新に失敗した場合" do
      it "株情報編集画面のまま、バリデーションエラーメッセージが表示されること" do
        fill_in "株名称", with: ""
        click_on "株情報を更新"
        expect(current_path).to eq plant_path(plant)
        expect(page).to have_content "株名称を入力してください"
      end
    end

    context "キャンセルボタンを押下した場合" do
      it "株詳細確認画面に遷移すること" do
        click_on "キャンセル"
        expect(current_path).to eq plant_path(plant)
      end
    end
  end

  describe "ログインユーザーの株情報以外操作できないようにする機能のテスト" do
    it "他のユーザーの株情報詳細の確認が行えないこと" do
      visit plant_path(not_target_users_plant)
      expect(current_path).to eq root_path
      expect(page).to have_content "自分が所持している株以外の参照・編集・削除等の操作は行えません"
    end

    it "他のユーザーの株情報編集が行えないこと" do
      visit edit_plant_path(not_target_users_plant)
      expect(current_path).to eq root_path
      expect(page).to have_content "自分が所持している株以外の参照・編集・削除等の操作は行えません"
    end
  end
end
