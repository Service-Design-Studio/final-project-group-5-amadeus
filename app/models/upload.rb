require 'zip'
require 'pdf-reader'
require 'json'

class Upload < ApplicationRecord
  require_relative 'nltk_model.rb'

  has_one_attached :file
  validates :file, presence: true
  validates :file, file_content_type: { allow: ['application/pdf', 'application/zip'], message: "ZIP should contain PDFs only!" }
  has_many :uploadlinks, dependent: :destroy
  has_many :topics, through: :uploadlinks
  has_many :upload_category_links, dependent: :destroy
  has_many :categories, through: :upload_category_links

  private

  def self.verify_tag(upload, topic_name)
    status = "fail"

    upload.uploadlinks.each do |uploadlink|
      if uploadlink.topic.name == topic_name
        status = "exist"
      end
    end

    if (topic_name == "") || topic_name.nil?
      msg = flash_message_tag::INVALID_TAG
    elsif topic_name.length >= 15
      msg = flash_message_tag::LENGTHY_TAG
    elsif topic_name.match(/\W/)
      msg = flash_message_tag.get_special_characters(topic_name)
    elsif status == "exist"
      status = "fail"
      msg = flash_message_tag.get_duplicate_tag(topic_name)
    else
      status = "success"
      msg = ""
      new_topic = Topic.friendly.find_by(name: topic_name)
      if new_topic.nil?
        new_topic = Topic.create(name: topic_name)
        Uploadlink.create(upload_id: upload.id, topic_id: new_topic.id)
      else
        Uploadlink.create(upload_id: upload.id, topic_id: new_topic.id)
      end
    end
    return { status: status, msg: msg }
  end

  def self.verify_category(upload, category_name)
    status = "fail"

    if get_linked_category(upload).category.name == category_name
      status = "exist"
    end

    if (category_name == "") || category_name.nil?
      msg = flash_message_category::INVALID_CAT
    elsif category_name.length >= 15
      msg = flash_message_category::LENGTHY_CAT
    elsif category_name.match(/\W/)
      msg = flash_message_category.get_special_characters(category_name)
    elsif status == "exist"
      msg = flash_message_category.get_already_assigned_category(category_name)
    else
      status = "success"
      msg = ""
      new_category = Category.friendly.find_by(name: category_name)
      get_linked_category(upload).destroy
      if new_category.nil?
        new_category = Category.create(name: category_name)
        UploadCategoryLink.create(upload_id: upload.id, category_id: new_category.id)
      else
        UploadCategoryLink.create(upload_id: upload.id, category_id: new_category.id)
      end
    end
    return { status: status, msg: msg }
  end

  def self.unzip_file(file, params)
    if File.extname(file) == '.zip'
      Zip::File.open(file) do |zipfile|
        zipfile.each do |entry|
          if entry.file? && entry.to_s.include?(".pdf")
            new_upload = Upload.new
            new_upload.file.attach(io: StringIO.new(entry.get_input_stream.read), filename: entry.name)
            content = get_pdf_text(entry)
            nltk_response = NltkModel.request(content)
            summary = nltk_response[:summary].gsub(/(\\\")/, "")
            tags_dict = nltk_response[:tags]
            category = nltk_response[:category]
            # zero_shot_response = ZeroShotCategoriser.request(summary, Category.get_category_bank)
            # category = zero_shot_response[:category]
            new_upload.content = content
            new_upload.summary = summary
            new_upload.save
            set_upload_tag(new_upload.id, tags_dict)
            set_upload_category(new_upload.id, category)
          end
        end
      end
    end
    @params = params
  end

  def self.get_pdf_text(pdf)
    content = ""
    reader = PDF::Reader.new(StringIO.new(pdf.get_input_stream.read))
    reader.pages.each do |page|
      content.concat(preprocess_text(page.text))
    end
    return content.to_json
  end

  def self.preprocess_text(text)
    text = text.gsub(/^.*\u0026/, "")                  # strip header before main text
    text = text.strip.delete("\t\r\n")                 # strip whitespace
    text = text.gsub(/[^\x00-\x7F]/, " ")              # strip non-ASCII
    text = text.gsub(/(?<=[.,?!;])(?=[^\s])/, " ")     # add whitespace after punctuation
    text = text.gsub(/\s+(?=\d)/, "")                  # remove whitespace added between number
    text = text.gsub(/(?<=[a-z1-9])(?=[A-Z])/, " ")    # add whitespace before capital letter
    text.squeeze(' ')
  end

  def self.set_upload_tag(upload_id, topics)
    topics.each do |topic, frequency|
      new_topic = Topic.friendly.find_by(name: topic)
      if new_topic.nil?
        new_topic = Topic.new(:name => topic)
        new_topic.save!
        Uploadlink.create(upload_id: upload_id, topic_id: new_topic.id)
      else
        Uploadlink.create(upload_id: upload_id, topic_id: new_topic.id)
      end
    end
  end

  def self.set_upload_category(upload_id, category)
    new_category = Category.friendly.find_by(name: category)
    if new_category.nil?
      new_category = Category.new(:name => category)
      new_category.save!
      UploadCategoryLink.create(upload_id: upload_id, category_id: new_category.id)
    else
      UploadCategoryLink.create(upload_id: upload_id, category_id: new_category.id)
    end
  end

  # Generates random upload_links associated to the upload, remove when ML is implemented
  def self.seed_pdf_tag(upload_id)
    topic_ids = Topic.pluck(:id)
    n = Random.rand(1...topic_ids.length)
    n.times do
      topic_id = topic_ids.sample
      similarity = Random.rand(1...100)
      Uploadlink.create(upload_id: upload_id, topic_id: topic_id)
      topic_ids.delete(topic_id)
    end
  end

  def self.get_all_topics
    Topic.all.collect(&:name)
  end

  def self.get_all_categories
    Category.all.collect(&:name)
  end

  def self.get_linked_topics(upload)
    upload.uploadlinks.all
  end

  def self.get_uploadlink(upload, topic)
    upload.uploadlinks.find_by(topic_id: topic.id)
  end

  def self.get_linked_category(upload)
    upload.upload_category_links.first
  end

  def self.get_cleaned_summary(upload)
    upload.summary.split(/\s+/, 100 + 1)[0...100].join(' ')
  end

  def self.get_cleaned_filename(upload)
    upload.file.filename.to_s.sub(/(?<=.)\..*/, '')
  end

  def self.flash_message_tag
    FlashString::TagString
  end

  def self.flash_message_category
    FlashString::CategoryString
  end
end