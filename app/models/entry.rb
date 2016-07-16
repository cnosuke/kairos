require 'rest-client'

class Entry < ActiveRecord::Base
  belongs_to :company

  class << self
    def initialize_with_tdnet_client_attributes(attrs)
      company = setup_company(attrs[:code].to_i, attrs[:name])
      entry = company.entries.create(
        convert_attributes(attrs)
      )
      entry.save_pdf

      entry
    end

    private

    def setup_company(code, name)
      company = Company.find_or_initialize_by(code: code)
      company.name = name
      company.save

      company
    end

    def convert_attributes(attrs)
      {
        title:        attrs[:title],
        kind:         attrs[:kind],
        original_pdf: attrs[:pdf],
        xbrl:         attrs[:xbrl],
        published_at: attrs[:time],
      }
    end
  end

  def save_pdf
    pdf = getfile(self.original_pdf)
    if pdf.present?
      hash = digest_pdf(pdf)
      open(file_path(hash), "wb") { |io| io.write pdf }
      self.update(pdf_digest: hash)
    end
  end

  def file_path(h = nil)
    fpath = "public/pdf/#{h || self.pdf_digest}.pdf"
    File.expand_path(fpath, Rails.root)
  end

  def download_filename
    "#{company.code}_#{published_at.strftime("%Y%m%d-%H%M")}.pdf"
  end

  private

  def digest_pdf(pdf)
    @pdf_hash ||= Digest::SHA1.hexdigest(pdf)
  end

  def getfile(url)
    res = RestClient.get url
    res.code == 200 ? res.body : nil
  end
end
