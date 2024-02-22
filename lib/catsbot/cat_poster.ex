defmodule CatPoster do
  def post_next_cat() do
    cats_dir = Application.fetch_env!(:catsbot, :cats_folder)

    case File.ls!(cats_dir) do
      [] ->
        IO.puts("no cats found :(")
        notify_no_cats()

      [image | _] ->
        full_image_path = "#{cats_dir}/#{image}"
        IO.puts("will attempt to post #{full_image_path}")
        post_next_cat(full_image_path)
        File.rm!(full_image_path)
    end
  end

  def notify_no_cats() do
    admin = Application.fetch_env!(:catsbot, :admin_user)
    text = "#{admin} no more cat images to post :("

    post_status_update(%{
      status: text,
      visibility: "direct"
    })
  end

  def post_next_cat(file) do
    media_id = upload_media(file)

    post_status_update(%{
      media_ids: [media_id],
      visibility: "public"
    })
  end

  def upload_media(file) do
    {:ok, file_contents} = File.read(file)

    multipart =
      Multipart.new()
      |> Multipart.add_part(
        Multipart.Part.text_field("An image with one or more cats in it", "description")
      )
      |> Multipart.add_part(
        Multipart.Part.file_content_field(file, file_contents, :file, filename: file)
      )

    content_length = Multipart.content_length(multipart)
    content_type = Multipart.content_type(multipart, "multipart/form-data")

    token = Application.fetch_env!(:catsbot, :mastodon_access_token)

    headers = [
      {"authorization", "Bearer #{token}"},
      {"Content-Type", content_type},
      {"Content-Length", to_string(content_length)}
    ]

    mastodon_host = Application.fetch_env!(:catsbot, :mastodon_host)
    url = "https://#{mastodon_host}/api/v2/media"
    resp = Req.post!(url, headers: headers, body: Multipart.body_stream(multipart))

    case resp.body do
      %{"id" => id} -> id
      _ -> 
        resp |> IO.inspect()
        raise "Failed to upload the image"
    end

  end

  def post_status_update(data) do
    token = Application.fetch_env!(:catsbot, :mastodon_access_token)

    headers = [
      {"authorization", "Bearer #{token}"},
      {"content-type", "application/json"}
    ]

    mastodon_host = Application.fetch_env!(:catsbot, :mastodon_host)
    url = "https://#{mastodon_host}/api/v1/statuses"

    resp = Req.post!(url, headers: headers, json: data)

    resp |> IO.inspect()

    resp
  end
end
