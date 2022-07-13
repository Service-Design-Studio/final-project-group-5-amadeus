require 'zip'
require 'pdf-reader'
require 'json'

class Upload < ApplicationRecord
  require_relative 'nltk_model.rb'
  has_one_attached :file
  validate :validate_attachment_filetype
  has_many :uploadlinks, dependent: :destroy
  has_many :topics, through: :uploadlinks

  private

  def validate_attachment_filetype
    return unless file.attached?

    unless file.content_type.in?(%w[application/pdf])
      errors.add(:file, 'must be a ZIP!')
    end
  end

  def self.unzip_file(file, params)
    Zip::File.open(file) do |zipfile|
      zipfile.each do |entry|
        if entry.file?
          new_upload = Upload.new
          new_upload.file.attach(io: StringIO.new(entry.get_input_stream.read), filename: entry.name)
          content = get_pdf_text(entry)
          response = NLTK_Model.request(content)
          summary = response[:summary]
          topics = response[:topics]
          new_upload.content = content
          new_upload.summary = summary
          new_upload.save
          set_pdf_topic(new_upload.id, topics)
        end
      end
    end
    @params = params
  end

  def self.get_pdf_text(pdf)
    content = ""
    reader = PDF::Reader.new(StringIO.new(pdf.get_input_stream.read))
    reader.pages.each do |page|
      content.concat(page.text.strip.gsub("\n", ' ').squeeze(' '))
    end
    return content.to_json
  end

  def self.set_pdf_topic(upload_id, topics)
    topics.each do |topic_name, frequency|
      topic = Topic.new(:name => topic_name)
      topic.save
      similarity = Random.rand(1...100)
      Uploadlink.create(upload_id: upload_id, topic_id: topic.id, similarity: similarity)
    end
  end

  # Generates random upload_links associated to the upload, remove when ML is implemented
  def self.seed_pdf_topic(upload_id)
    topic_ids = Topic.pluck(:id)
    n = Random.rand(1...topic_ids.length)
    n.times do
      topic_id = topic_ids.sample
      similarity = Random.rand(1...100)
      Uploadlink.create(upload_id: upload_id, topic_id: topic_id, similarity: similarity)
      topic_ids.delete(topic_id)
    end
  end

  def self.get_all_topics
    Topic.all.collect(&:name)
  end

  def self.get_linked_topics(upload)
    upload.uploadlinks.order(:similarity).reverse
  end
end