module FlashString
  TO_LOGIN = "You must be logged in to access this section"
  DELETED = "Successfully deleted!"

  class UploadString
    UPLOAD_DELETED = "Upload deleted!"
    UPLOAD_SOME_FAILED = "Some pdfs failed to be parse!"
    INVALID_SUMMARY = "Summary cannot be blank!"
    SAME_SUMMARY = "No change to summary!"
    SUMMARY_UPDATED = "Summary updated!"
    SHORT_SUMMARY = "Summary must be at least 100 characters!"
    LONG_SUMMARY = "Summary must be less than 2500 characters!"
    SPACE_SUMMARY = "Summary cannot be all spaces!"
    SPECIAL_CHARACTERS = "Summary cannot contain only special characters!"
  end

  class TagString
    INVALID_TAG = "Invalid tag input!"
    LENGTHY_TAG = "Tag name is too long!"
    def self.get_added_tag(tag)
      "%{tag} added." % {tag:tag}
    end

    def self.get_deleted_tag(tag)
      "Deleted %{tag}." % {tag: tag}
    end

    def self.get_duplicate_tag(tag)
      "Tag %{tag} already exists!" % {tag: tag}
    end

    def self.get_special_characters(tag)
      "Tag %{tag} contains special characters!" % {tag: tag}
    end
  end

  class CategoryString
    INVALID_CAT = "Invalid category input!"
    LENGTHY_CAT = "Category name is too long!"
    def self.get_added_category(category)
      "Set new category: %{category}." % {category:category}
    end

    def self.get_linked_category(category)
      "Replaced with existing category: %{category}." % {category:category}
    end

    def self.get_deleted_category(category)
      "Deleted %{category}." % {category: category}
    end

    def self.get_duplicate_category(category)
      "Category %{category} already exists!" % {category: category}
    end

    def self.get_already_assigned_category(category)
      "No change!" % {category: category}
    end

    def self.get_special_characters(category)
      "Category %{category} contains special characters!" % {category: category}
    end
  end
end