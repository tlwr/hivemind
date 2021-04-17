require "bcrypt"
require "sequel"
require "time"

def db_filepath
  {
    "development" => "sqlite:///tmp/hivemind-development.db",
    "production" => "/opt/hivemind/fs/hivemind-production.db",
  }.fetch(ENV.fetch("RACK_ENV", "development"))
end

DB = ENV["RACK_ENV"] == "test" ? Sequel.sqlite : Sequel.connect(db_filepath)

Sequel::Model.plugin :timestamps

Sequel.extension :migration
Sequel::Migrator.run(DB, File.join(__dir__, "db", "migrations"))

class User < Sequel::Model
  attr_reader :password
  attr_accessor :password_confirmation

  one_to_many :uploaded_epubs, class: :EPub, key: :uploader_id

  def password=(plain)
    @password = plain
    self.password_digest = BCrypt::Password.create(plain, cost: 10)
  end

  def authenticate(plain)
    return self if BCrypt::Password.new(password_digest) == plain
  end

  def validate
    super

    errors.add :password, "is not present" if password.nil? || password.empty?
    errors.add :password, "is too short" if !password.nil? && password.length < 12
    errors.add :password, "and password_confirmation do not match" unless password == password_confirmation
  end
end

class EPub < Sequel::Model
  many_to_one :uploader, class: :User, key: :uploader_id

  def tags
    tags_arr.split("\n").reject?(&:empty?)
  end

  def tags=(tags_arr)
    self.tags = tags_arr.join("\n").reject?(&:empty?)
  end
end

if ["development", "test"].include?ENV["RACK_ENV"]
  unless User.find(username: "test")
    test_user = User.new(username: "test")
    test_user.password = "test-user-password"
    test_user.password_confirmation = "test-user-password"
    test_user.save
  end
end
