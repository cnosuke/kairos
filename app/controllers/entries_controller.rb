class EntriesController < ApplicationController
  def pdf
    entry = find_entry

    send_file entry.file_path, filename: entry.download_filename
  end

  def redirect_pdf
    entry = find_entry

    redirect_to public_file_path(entry)
  end

  private

  def public_file_path(entry)
    "/pdf/#{entry.pdf_digest}.pdf"
  end

  def find_entry
    Entry.find(params[:entry_id])
  end
end
