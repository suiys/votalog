require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe "バリデーション関連のテスト" do
    let(:user_without_name) { build(:user, name: nil) }
    let(:user_without_email) { build(:user, email: nil) }
    let(:user_without_password) { build(:user, password: nil) }
    let(:user_with_4_digits_zipcode) { build(:user, zipcode: 1234) }
    let(:user_with_5_digits_zipcode) { build(:user, zipcode: 12345) }
    let(:user_with_7_digits_zipcode) { build(:user, zipcode: 1234567) }
    let(:user_with_8_digits_zipcode) { build(:user, zipcode: 12345678) }
    let(:user_zipcode_with_point) { build(:user, zipcode: 123.456) }

    it "ユーザー名、メールアドレス、パスワードがあればバリデーションをパスすること" do
      expect(user).to be_valid
    end

    it "ユーザー名がないとバリデーションをパスしないこと" do
      user_without_name.valid?
      expect(user_without_name.errors[:name]).to include("を入力してください")
    end

    it "メールアドレスがないとバリデーションをパスしないこと" do
      user_without_email.valid?
      expect(user_without_email.errors[:email]).to include "を入力してください"
    end

    it "パスワードがないとバリデーションをパスしないこと" do
      user_without_password.valid?
      expect(user_without_password.errors[:password]).to include "を入力してください"
    end

    it "郵便番号が存在する場合、4桁以下だとバリデーションをパスしないこと" do
      user_with_4_digits_zipcode.valid?
      expect(user_with_4_digits_zipcode.errors[:zipcode]).to include "は5文字以上で入力してください"
    end

    it "郵便番号が存在する場合、5桁以上だとバリデーションをパスすること" do
      expect(user_with_5_digits_zipcode).to be_valid
    end

    it "郵便番号が存在する場合、7桁以下だとバリデーションをパスすること" do
      expect(user_with_7_digits_zipcode).to be_valid
    end

    it "郵便番号が存在する場合、8桁以上だとバリデーションをパスしないこと" do
      user_with_8_digits_zipcode.valid?
      expect(user_with_8_digits_zipcode.errors[:zipcode]).to include "は7文字以内で入力してください"
    end

    it "郵便番号が存在する場合、整数以外を入力するとバリデーションをパスしないこと" do
      user_zipcode_with_point.valid?
      expect(user_zipcode_with_point.errors[:zipcode]).to include "は整数で入力してください"
    end
  end
  describe ".find_or_create_guest_user" do
    it "ユーザー名が「ゲストユーザー」のゲストアカウントが作成されていること" do
      guest_user = User.find_or_create_guest_user
      expect(guest_user.name).to eq "ゲストユーザー"
    end
  end
  describe "#format_zipcode" do
    let(:user_with_5_digits_zipcode) { create(:user, zipcode: 12345) }
    let(:user_with_6_digits_zipcode) { create(:user, zipcode: 123456) }
    let(:user_with_7_digits_zipcode) { create(:user, zipcode: 1234567) }

    it "5桁の郵便番号が0埋めされて7桁になり、3桁 - 4桁にフォーマットされること" do
      expect(user_with_5_digits_zipcode.format_zipcode(user_with_5_digits_zipcode.zipcode)).to eq "001 - 2345"
    end

    it "6桁の郵便番号が0埋めされて7桁になり、3桁 - 4桁にフォーマットされること" do
      expect(user_with_6_digits_zipcode.format_zipcode(user_with_6_digits_zipcode.zipcode)).to eq "012 - 3456"
    end

    it "7桁の郵便番号が3桁 - 4桁にフォーマットされること" do
      expect(user_with_7_digits_zipcode.format_zipcode(user_with_7_digits_zipcode.zipcode)).to eq "123 - 4567"
    end
  end
  describe "#get_users_location" do
    it "実在する郵便番号を含むGETリクエストを発行してheartrails APIを叩いた際に、郵便番号に対応した緯度と経度がレスポンスに含まれていること" do
      expect(user.get_users_location("6120051")).to eq ["34.948035", "135.767568"]
    end

    it "実在しない郵便番号を含むGETリクエストを発行してheartrails APIを叩いた際に、緯度と経度がnilになっていること" do
      expect(user.get_users_location("1234567")).to match_array [nil, nil]
    end
  end
end
