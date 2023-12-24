require 'rails_helper'

RSpec.describe "Logs", type: :system do
  let(:user) { create(:user) }
  let!(:plant) { create(:plant, user: user) }
  let(:log) { create(:log, user: user, plant: plant) }

  before do
    login_as(user, scope: :user)
  end

  describe "新規ログ作成機能のテスト" do
    before do
      visit new_log_path
    end

    context "新規ログ追加に成功した場合" do
      it "作成したログの詳細画面に遷移し、保存成功のフラッシュメッセージが表示されること" do
        fill_in "記録日時", with: Time.zone.now
        select plant.name, from: "株"
        check "水やり"
        click_on "ログを追加"
        expect(page).to have_content "#{Time.zone.now.strftime("%Y/%m/%d")} の #{plant.name} ログ"
        expect(page).to have_content "新しいログを保存しました"
      end
    end

    context "新規ログ追加に失敗した場合" do
      it "新規ログ追加画面のまま、登録失敗のフラッシュメッセージが表示されること" do
        fill_in "記録日時", with: Time.zone.now
        click_on "ログを追加"
        expect(current_path).to eq logs_path
        expect(page).to have_content "新しいログの保存に失敗しました"
      end
    end

    context "キャンセルボタンを押下した場合" do
      it "トップページに遷移すること" do
        click_on "キャンセル"
        expect(current_path).to eq root_path
      end
    end
  end

  describe "ログ詳細確認機能のテスト" do
    before do
      visit log_path(log)
    end

    it "ログタイトルと記録日時が表示されること" do
      expect(page).to have_content "#{log.start_time.strftime("%Y/%m/%d")} の #{log.plant.name} ログ"
      expect(page).to have_content log.start_time.strftime("%Y/%m/%d %H:%M")
    end

    context "ログを編集ボタンを押下した場合" do
      it "ログ編集画面へ遷移すること" do
        click_on "ログを編集"
        expect(current_path).to eq edit_log_path(log)
      end
    end

    context "ログを削除ボタンを押下した場合", js: true do
      it "confirmダイアログでOKすると、株詳細画面に遷移しフラッシュメッセージが表示されること" do
        page.accept_confirm("本当にこのログを削除してよろしいですか？") do
          click_on "ログを削除"
        end
        expect(current_path).to eq plant_path(log.plant)
        expect(page).to have_content "ログを削除しました"
      end
      it "confirmダイアログでキャンセルすると、ログ詳細確認画面のままになること" do
        page.dismiss_confirm("本当にこのログを削除してよろしいですか？") do
          click_on "ログを削除"
        end
        expect(current_path).to eq log_path(log)
      end
    end

    context "戻るボタンを押下した場合" do
      it "株詳細確認画面に遷移すること" do
        click_on "戻る"
        expect(current_path).to eq plant_path(log.plant)
      end
    end
  end

  describe "ログ編集機能のテスト" do
    before do
      visit edit_log_path(log)
    end

    it "記録日時と株の項目がフォームに入力された状態になっていること" do
      expect(page).to have_field "記録日時", with: log.start_time.strftime("%Y-%m-%dT%T")
      expect(page).to have_select "株", selected: log.plant.name
    end

    context "ログ情報を編集し、更新に成功した場合" do
      it "ログ詳細確認画面に遷移し、更新成功のフラッシュメッセージが表示されること" do
        check "水やり"
        click_on "ログを更新"
        expect(current_path).to eq log_path(log)
        expect(page).to have_content "ログを更新しました"
      end
    end

    context "ログ情報を編集したが、更新に失敗した場合" do
      it "ログ編集画面のまま、バリデーションエラーメッセージが表示されること" do
        fill_in "記録日時", with: ""
        click_on "ログを更新"
        expect(current_path).to eq log_path(log)
        expect(page).to have_content "記録日時を入力してください"
      end
    end

    context "キャンセルボタンを押下した場合" do
      it "ログ詳細確認画面に遷移すること" do
        click_on "キャンセル"
        expect(current_path).to eq log_path(log)
      end
    end
  end

  describe "ログスタンプ一覧機能のテスト" do
    let!(:watered_log) { create(:log, is_watered: true, user: user, plant: plant) }
    let!(:fertilized_log) { create(:log, is_fertilized: true, user: user, plant: plant) }
    let!(:replanted_log) { create(:log, is_replanted: true, user: user, plant: plant) }

    before do
      visit plant_path(plant)
    end

    it "当月のカレンダーが表示されること" do
      this_month = Time.zone.now.strftime("%Y 年 %m月")
      within ".simple-calendar" do
        expect(page).to have_content this_month
      end
    end

    context "カレンダー上のアイコンを押下した場合" do
      it "該当のログ詳細画面に遷移すること" do
        click_on "水やりアイコン"
        expect(current_path).to eq log_path(watered_log)
        visit plant_path(plant)
        click_on "肥料/栄養剤アイコン"
        expect(current_path).to eq log_path(fertilized_log)
        visit plant_path(plant)
        click_on "植替えアイコン"
        expect(current_path).to eq log_path(replanted_log)
      end
    end

    context "カレンダーの先月ボタンを押下した場合" do
      it "先月のカレンダーが表示されること" do
        click_on "先月"
        last_month = Time.zone.now.prev_month
        within ".simple-calendar" do
          expect(page).to have_content last_month.strftime("%Y 年 %-m月")
        end
      end
    end

    context "カレンダーの翌月ボタンを押下した場合" do
      it "翌月のカレンダーが表示されること" do
        click_on "翌月"
        next_month = Time.zone.now.next_month
        within ".simple-calendar" do
          expect(page).to have_content next_month.strftime("%Y 年 %-m月")
        end
      end
    end

    context "カレンダーの今日ボタンを押下した場合" do
      it "今月のカレンダーが表示されること" do
        click_on "今日"
        this_month = Time.zone.now.strftime("%Y 年 %-m月")
        within ".simple-calendar" do
          expect(page).to have_content this_month
        end
      end
    end
  end

  describe "ログインユーザーのログ情報以外操作できないようにする機能のテスト" do
    let(:another_user) { create(:user) }
    let!(:not_target_users_log) { create(:log, user: another_user) }

    it "他のユーザーのログ詳細の確認が行えないこと" do
      visit log_path(not_target_users_log)
      expect(current_path).to eq root_path
      expect(page).to have_content "自分のお世話ログ以外の参照・編集・削除等の操作は行えません"
    end

    it "他のユーザーのログ編集が行えないこと" do
      visit edit_log_path(not_target_users_log)
      expect(current_path).to eq root_path
      expect(page).to have_content "自分のお世話ログ以外の参照・編集・削除等の操作は行えません"
    end
  end
end
