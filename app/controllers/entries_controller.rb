class EntriesController < ApplicationController
  def pdf
    entry = find_entry

    send_file entry.file_path, filename: entry.download_filename
  end

  private

  def find_entry
    Entry.find(params[:entry_id])
  end
end
