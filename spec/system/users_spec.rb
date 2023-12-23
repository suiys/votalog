require 'rails_helper'

RSpec.describe "Users", type: :system do
  let(:user) { create(:user) }
  let(:user_with_zipcode) { create(:user, zipcode: 6120051) }

  describe "ログイン画面（/users/sign_in）のテスト" do
    before do
      visit new_user_session_path
    end
    context "正しいメールアドレスとパスワードを入力した場合" do
      it "トップページに遷移し、ログイン成功のフラッシュメッセージが表示されること" do
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        within "#new_user" do
          click_on "ログイン"
        end
        expect(current_path).to eq root_path
        expect(page).to have_content "ログインしました"
      end
    end
    context "正しいメールアドレスとパスワードを入力しなかった場合" do
      it "ログイン画面のまま、警告のフラッシュメッセージが表示されること" do
        fill_in "メールアドレス", with: ""
        fill_in "パスワード", with: user.password
        within "#new_user" do
          click_on "ログイン"
        end
        expect(current_path).to eq new_user_session_path
        expect(page).to have_content "メールアドレスまたはパスワードが違います"
      end
    end
    context "新規作成リンクを押下した場合" do
      it "アカウント新規作成画面に遷移すること" do
        within ".caption" do
          click_on "新規作成"
        end
        expect(current_path).to eq new_user_registration_path
      end
    end
    context "ゲストログインリンクを押下した場合" do
      it "トップページに遷移し、ログイン成功のフラッシュメッセージが表示されること" do
        within ".caption" do
          click_on "ゲストログイン"
        end
        expect(current_path).to eq root_path
        expect(page).to have_content "ゲストユーザーとしてログインしました"
      end
    end
  end

  describe "新規作成画面(/users/sign_up)のテスト" do
    before do
      visit new_user_registration_path
    end
    context "有効なユーザー名、メールアドレス、パスワードを入力した場合" do
      it "トップページに遷移し、新規登録成功のフラッシュメッセージが表示されること" do
        fill_in "ユーザー名", with: "testuser"
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "password"
        fill_in "パスワード（確認用）", with: "password"
        within "#new_user" do
          click_on "新規登録"
        end
        expect(current_path).to eq root_path
        expect(page).to have_content "アカウント登録が完了しました"
      end
    end
    context "既に存在するユーザーのアカウントを新規登録しようとした場合" do
      it "新規作成画面のまま、バリデーションエラーメッセージが表示されること" do
        fill_in "ユーザー名", with: user.name
        fill_in "メールアドレス", with: user.email
        fill_in "パスワード", with: user.password
        fill_in "パスワード（確認用）", with: user.password
        within "#new_user" do
          click_on "新規登録"
        end
        expect(current_path).to eq user_registration_path
        expect(page).to have_content "メールアドレスはすでに存在します"
      end
    end
    context "ログインリンクを押下した場合" do
      it "ログイン画面に遷移すること" do
        within ".login-caption" do
          click_on "ログイン"
        end
        expect(current_path).to eq new_user_session_path
      end
    end
    context "ゲストログインリンクを押下した場合" do
      it "トップページに遷移し、ログイン成功のフラッシュメッセージが表示されること" do
        within ".guest-login-caption" do
          click_on "ゲストログイン"
        end
        expect(current_path).to eq root_path
        expect(page).to have_content "ゲストユーザーとしてログインしました"
      end
    end
  end

  describe "アカウント情報確認画面(/users/account)のテスト" do
    before do
      login_as(user, scope: :user)
      visit users_account_path
    end
    it "ユーザー名、メールアドレス、パスワードの項目が表示されていること" do
      expect(page).to have_content user.name
      expect(page).to have_content user.email
      expect(page).to have_content "******"
    end
    context "登録情報の変更ボタンを押下した場合" do
      it "アカウント情報編集画面に遷移すること" do
        click_on "登録情報の変更"
        expect(current_path).to eq edit_user_registration_path
      end
    end
    context "アカウント削除ボタンを押下した場合", js: true do
      it "confirmダイアログでOKすると、ログアウトした状態でトップページに遷移しフラッシュメッセージが表示されること" do
        page.accept_confirm("本当にこのアカウントを削除してよろしいですか？") do
          click_on "このアカウントを削除する"
        end
        expect(current_path).to eq root_path
        expect(page).to have_content "Votalogとは"
        expect(page).to have_content "アカウントを削除しました"
      end
    end
  end

  describe "アカウント情報編集画面(/users/edit)のテスト" do
    before do
      login_as(user, scope: :user)
      visit edit_user_registration_path
    end
    it "必須項目のユーザー名とメールアドレスがフォームに表示されていること" do
      expect(page).to have_field "ユーザー名", with: user.name
      expect(page).to have_field "メールアドレス", with: user.email
    end
    context "アカウント情報を編集し、変更の保存に成功した場合" do
      it "アカウント情報確認画面に遷移し、更新成功のフラッシュメッセージが表示されること" do
        fill_in "ユーザー名", with: "testuser"
        fill_in "現在のパスワード", with: user.password
        click_on "変更を保存"
        expect(current_path).to eq users_account_path
        expect(page).to have_content "アカウント情報を変更しました"
      end
    end
    context "アカウント情報を編集したが、変更の保存に失敗した場合" do
      it "アカウント情報編集画面のまま、バリデーションエラーメッセージが表示されること" do
        fill_in "ユーザー名", with: "testuser"
        click_on "変更を保存"
        expect(current_path).to eq user_registration_path
        expect(page).to have_content "変更には現在のパスワードが必要です"
      end
    end
    context "キャンセルボタンを押下した場合" do
      it "アカウント情報確認画面に遷移すること" do
        click_on "キャンセル"
        expect(current_path).to eq users_account_path
      end
    end
  end

  describe "ユーザー設定画面(/users/settings)のテスト" do
    before do
      login_as(user_with_zipcode, scope: :user)
      visit users_settings_path
    end
    it "郵便番号が表示されていること" do
      expect(page).to have_content "612 - 0051"
    end
    context "設定の変更ボタンを押下した場合" do
      it "ユーザー設定編集画面に遷移すること" do
        click_on "設定の変更"
        expect(current_path).to eq users_settings_edit_path
      end
    end
  end

  describe "ユーザー設定編集画面(/users/settings/edit)のテスト" do
    before do
      login_as(user_with_zipcode, scope: :user)
      visit users_settings_edit_path
    end
    context "郵便番号を変更し、変更の保存に成功した場合" do
      it "ユーザー設定画面に遷移し、更新成功のフラッシュメッセージが表示されること" do
        fill_in "郵便番号", with: 6120054
        click_on "変更を保存"
        expect(current_path).to eq users_settings_path
        expect(page).to have_content "ユーザー設定を更新しました"
      end
    end
    context "郵便番号を変更したが、変更の保存に失敗した場合" do
      it "ユーザー設定編集画面のまま、更新失敗のフラッシュメッセージが表示されること" do
        fill_in "郵便番号", with: 1234567
        click_on "変更を保存"
        expect(current_path).to eq users_settings_edit_path
        expect(page).to have_content "位置情報の取得に失敗しました。郵便番号が誤っていないか確認してください"
      end
    end
    context "キャンセルボタンを押下した場合" do
      it "ユーザー設定変更画面に遷移すること" do
        click_on "キャンセル"
        expect(current_path).to eq users_settings_path
      end
    end
  end

  describe "未ログイン時のナビゲーションバー部分のテスト" do
    before do
      visit root_path
    end

    it "ログインリンクが存在し、押下するとログイン画面に遷移すること" do
      within ".navbar" do
        expect(page).to have_content "ログイン"
        click_on "ログイン"
        expect(current_path).to eq new_user_session_path
      end
    end
    it "新規登録リンクが存在し、押下すると新規登録画面に遷移すること" do
      within ".navbar" do
        expect(page).to have_content "新規登録"
        click_on "新規登録"
        expect(current_path).to eq new_user_registration_path
      end
    end
    it "ゲストログインリンクが存在し、押下するとトップページの表示内容が切り替わること" do
      within ".navbar" do
        expect(page).to have_content "ゲストログイン"
        click_on "ゲストログイン"
      end
      expect(page).not_to have_content "Votalogとは"
      expect(page).to have_content "マイ多肉棚"
      expect(page).to have_content "ゲストユーザーとしてログインしました"
    end
    it "ロゴアイコンが存在すること" do
      within ".navbar" do
        expect(page).to have_selector ".logo-icon"
      end
    end
    it "ドロップダウンメニューが存在しないこと" do
      within ".navbar" do
        expect(page).not_to have_selector "#navbarDropdown"
      end
    end
  end

  describe "ログイン時のナビゲーションバー部分のテスト" do
    before do
      login_as(user, scope: :user)
      visit root_path
    end

    it "ロゴアイコンが存在すること" do
      within ".navbar" do
        expect(page).to have_selector ".logo-icon"
      end
    end
    it "ログインリンクが存在しないこと" do
      within ".navbar" do
        expect(page).not_to have_content "ログイン"
      end
    end
    it "新規登録リンクが存在しないこと" do
      within ".navbar" do
        expect(page).not_to have_content "新規登録"
      end
    end
    it "ゲストログインリンクが存在しないこと" do
      within ".navbar" do
        expect(page).not_to have_content "ゲストログイン"
      end
    end
    it "ドロップダウンメニューが存在すること" do
      within ".navbar" do
        expect(page).to have_content user.name
        expect(page).to have_content "アカウント"
        expect(page).to have_content "設定"
        expect(page).to have_content "ログアウト"
      end
    end
    it "ドロップダウンメニューのリンクからそれぞれのページへ遷移できること" do
      within ".navbar" do
        click_on "アカウント"
        expect(current_path).to eq users_account_path
        click_on "設定"
        expect(current_path).to eq users_settings_path
        click_on "ログアウト"
        expect(current_path).to eq root_path
      end
      expect(page).to have_content "ログアウトしました"
    end
  end

  describe "未ログイン時のトップページのテスト" do
    before do
      visit root_path
    end

    it "ファーストビューが表示されること" do
      expect(page).to have_selector ".firstview-wrapper"
    end
    it "機能説明セクションが表示されること" do
      expect(page).to have_selector ".about-wrapper"
    end
    context "ファーストビューの新規登録はこちらボタンを押下した場合" do
      it "新規登録画面へ遷移すること" do
        click_on "新規登録はこちら"
        expect(current_path).to eq new_user_registration_path
      end
    end
    context "ファーストビューのログインはこちらボタンを押下した場合" do
      it "ログイン画面へ遷移すること" do
        click_on "ログインはこちら"
        expect(current_path).to eq new_user_session_path
      end
    end
    context "ファーストビューのゲストログインはこちらボタンを押下した場合" do
      it "トップページの表示内容が切り替わること" do
        click_on "ゲストログインはこちら"
        expect(page).not_to have_content "Votalogとは"
        expect(page).to have_content "マイ多肉棚"
        expect(page).to have_content "ゲストユーザーとしてログインしました"
      end
    end
  end

  describe "ログイン時のトップページのテスト" do
    let!(:plant1) { create(:plant, next_water_day: Time.zone.today, next_replant_day: Time.zone.tomorrow, user: user) }
    let!(:plant2) { create(:plant, next_fertilizer_day: Time.zone.tomorrow, next_replant_day: Time.zone.tomorrow, user: user) }

    before do
      login_as(user, scope: :user)
      visit root_path
    end
    it "今日水やり予定の株に名称が表示され、押下すると株詳細画面に遷移すること" do
      within ".todays-water-schedule" do
        expect(page).to have_content plant1.name
        click_on plant1.name
        expect(current_path).to eq plant_path(plant1)
      end
    end
    it "明日肥料/栄養剤散布予定の株に名称が表示され、押下すると株詳細画面に遷移すること" do
      within ".tomorrows-fertilizer-schedule" do
        expect(page).to have_content plant2.name
        click_on plant2.name
        expect(current_path).to eq plant_path(plant2)
      end
    end
    it "明日植替え予定の株に名称が表示され、押下すると株詳細画面に遷移すること" do
      within ".tomorrows-replant-schedule" do
        expect(page).to have_content plant1.name
        expect(page).to have_content plant2.name
        click_on plant1.name
        expect(current_path).to eq plant_path(plant1)
        visit root_path
        click_on plant2.name
        expect(current_path).to eq plant_path(plant2)
      end
    end
    it "お世話予定の株がない項目はなしと表示されていること" do
      within ".todays-fertilizer-schedule" do
        expect(page).to have_content "なし"
      end
      within ".todays-replant-schedule" do
        expect(page).to have_content "なし"
      end
      within ".tomorrows-water-schedule" do
        expect(page).to have_content "なし"
      end
    end
  end
end
