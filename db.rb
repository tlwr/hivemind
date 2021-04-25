require "bcrypt"
require "json"
require "sequel"
require "time"

def db_filepath
  {
    "development" => "sqlite:///tmp/hivemind-development.db",
    "production" => "sqlite:///opt/hivemind/fs/hivemind-production.db",
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
  one_to_many :epub_statuses, class: :EPubUserStatus, key: :user_id

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
  many_to_many :collections, class: :Collection, join_table: :e_pub_collections

  def tags
    tags_arr.split("\n").reject?(&:empty?)
  end

  def tags=(tags_arr)
    self.tags = tags_arr.join("\n").reject?(&:empty?)
  end
end
EPub.plugin :lazy_attributes, :epub

class Event < Sequel::Model
  def self.record(kind, **metadata)
    e = Event.new
    e.kind = kind
    e.metadata = metadata
    e.save
    e
  end

  def metadata
    JSON.parse(raw_metadata).transform_keys { _1.to_sym }
  end

  def metadata=(hash)
    self.raw_metadata = hash.to_json
  end
end

class Collection < Sequel::Model
  many_to_many :epubs, class: :EPub,
    join_table: :e_pub_collections,
    left_key: :collection_id, left_primary_key: :id,
    right_key: :e_pub_id

  many_to_one :creator, class: :User, key: :creator_id
end

class EPubUserStatus < Sequel::Model
  many_to_one :user, class: :User, key: :user_id
  many_to_one :epub, class: :EPub, key: :e_pub_id
end
EPubUserStatus.plugin :update_or_create

if ["development", "test"].include?ENV["RACK_ENV"]
  unless User.find(username: "test")
    test_user = User.new(username: "test")
    test_user.password = "test-user-password"
    test_user.password_confirmation = "test-user-password"
    test_user.save
  end
end
