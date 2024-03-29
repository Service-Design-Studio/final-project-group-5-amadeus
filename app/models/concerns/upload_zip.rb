require 'zip'

class Upload 

  def self.verify_tag(upload, tag_name)
    status = "fail"

    upload.upload_tag_links.each do |upload_tag_link|
      if upload_tag_link.tag.name == tag_name
        status = "exist"
      end
    end

    if (tag_name == "") || tag_name.nil?
      msg = flash_message_tag::INVALID_TAG 
    elsif tag_name.length >= 15
      msg = flash_message_tag::INVALID_TAG 
    elsif tag_name[0].match(/\W/)
      msg = flash_message_tag::INVALID_TAG 
    elsif status == "exist"
      status = "fail"
      msg = flash_message_tag.get_duplicate_tag(tag_name)
    else
      status = "success"
      msg = ""
      new_tag = Tag.friendly.find_by(name: tag_name)
      if new_tag.nil?
        new_tag = Tag.create(name: tag_name)
        UploadTagLink.create(upload_id: upload.id, tag_id: new_tag.id)
      else
        UploadTagLink.create(upload_id: upload.id, tag_id: new_tag.id)
      end
    end
    return { status: status, msg: msg }
  end

  def self.verify_category(upload, category_name)
    status = "fail"

    linked_category = get_linked_category(upload)
    if !linked_category.nil? and linked_category.category.name == category_name
      status = "exist"
    end

    if (category_name == "") || category_name.nil?
      msg = flash_message_category::INVALID_CAT
    elsif category_name.length >= 30
      msg = flash_message_category::INVALID_CAT
    elsif !category_name.match(/^[a-zA-Z0-9_ ]*$/)
      msg = flash_message_category::INVALID_CAT
    elsif status == "exist"
      msg = flash_message_category.get_already_assigned_category(category_name)
    else
      status = "success"
      new_category = Category.find_by(name: category_name)
      if !linked_category.nil?
        get_linked_category(upload).destroy
      end
      if new_category.nil?
        new_category = Category.create(name: category_name)
        UploadCategoryLink.create(upload_id: upload.id, category_id: new_category.id)
        msg = flash_message_category.get_added_category(new_category[:name])
      else
        UploadCategoryLink.create(upload_id: upload.id, category_id: new_category.id)
        msg = flash_message_category.get_linked_category(new_category[:name])
      end
    end
    return { status: status, msg: msg }
  end

  def self.verify_summary(upload, summary)
    status = "fail"
    if (summary == "" || summary.nil?)
      msg = flash_message_summary::INVALID_SUMMARY
    elsif summary.split.size < 10 || summary.split.size > 100
      msg = flash_message_summary::INVALID_SUMMARY
    else
      status = "success"
      msg = flash_message_summary::SUMMARY_UPDATED
      upload.update(summary: summary)
    end
    return { status: status, msg: msg }
  end

  # SIDEKIQ - creates a zip_upload
  def self.save_zip_before_ML(file, params)
    # attach zip file in active records
    if File.extname(file) == ".zip"
      new_zip = ZipUpload.new
      new_zip.file.attach(io: StringIO.new(file.read), filename: file.to_s)
      new_zip.save
      # get the zip file id
      zip_id = new_zip.id
      # get the zip file name
      zip_name = new_zip.file.filename
      return { zip_id: zip_id, zip_name: zip_name }
    end
    @params = params
  end

  # SIDEKIQ - runs the nltk model
  def self.run_nltk(upload_id)
    upload = Upload.find(upload_id)
    content = upload.content
    nltk_response = NltkModel.request(content)
    summary = nltk_response[:summary]
    tags_dict = nltk_response[:tags]
    category = nltk_response[:category]
    # zero_shot_response = ZeroShotCategoriser.request(content, Category.get_category_bank)
    # category = zero_shot_response[:category]
    # summariser_response = Summariser.request(content)
    # summary = summariser_response[:summary]
    upload.summary = summary.gsub(/(\\\")/, "")
    upload.ml_status = "Complete"
    upload.save
    set_upload_tag(upload.id, tags_dict)
    if category != "No Category"
      set_upload_category(upload.id, category)
    end
  end

  def self.set_upload_tag(upload_id, tags)
    tags.each do |tag, frequency|
      new_tag = Tag.friendly.find_by(name: tag)
      if new_tag.nil?
        new_tag = Tag.new(:name => tag)
        new_tag.save!
        UploadTagLink.create(upload_id: upload_id, tag_id: new_tag.id)
      else
        UploadTagLink.create(upload_id: upload_id, tag_id: new_tag.id)
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
    tag_ids = Tag.pluck(:id)
    n = Random.rand(1...tag_ids.length)
    n.times do
      tag_id = tag_ids.sample
      UploadTagLink.create(upload_id: upload_id, tag_id: tag_id)
      tag_ids.delete(tag_id)
    end
  end

  def self.get_all_tags
    Tag.all.collect(&:name)
  end

  def self.get_all_categories
    Category.all.collect(&:name)
  end

  def self.get_linked_tags(upload)
    upload.upload_tag_links.all
  end

  def self.get_upload_tag_link(upload, tag)
    upload.upload_tag_links.find_by(tag_id: tag.id)
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

  def self.flash_message
    FlashString::UploadString
  end

  def self.flash_message_tag
    FlashString::TagString
  end

  def self.flash_message_category
    FlashString::CategoryString
  end

  def self.flash_message_summary
    FlashString::SummaryString
  end
end