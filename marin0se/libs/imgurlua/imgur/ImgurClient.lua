AuthWrapper = require('AuthWrapper')
require("strap")
lume = require("lume")
ImgurClient = class('ImgurClient')

function ImgurClient:init(client_id, client_secret, access_token, refresh_token)
	assert(client_id ~= nil, "Client ID cannot be nil.")
	self.client_id = client_id
	assert(client_secret ~= nil, "Client secret cannot be nil.")
	self.client_secret = client_secret

	self.access_token = access_token or nil
	self.refresh_token = refresh_token or nil

	self.allowed_album_fields = {
		'ids', 'title', 'description', 'privacy', 'layout', 'cover'
	}

	self.allowed_advanced_search_fields = {
		'q_all', 'q_any', 'q_exactly', 'q_not', 'q_type', 'q_size_px'
	}

	self.allowed_account_fields = {
		'bio', 'public_images', 'messaging_enabled', 'album_privacy', 'accepted_gallery_terms', 'username'
	}

	self.allowed_image_fields = {
		'album', 'name', 'title', 'description'
	}

	self.auth = nil

	if refresh_token then
		self.auth = new AuthWrapper(access_token, refresh_token, client_id, client_secret)
	end

	self.credits = self.get_credits()
end

function ImgurClient:set_user_auth(access_token, refresh_token)
	self.auth = AuthWrapper(access_token, refresh_token, self.client_id, self.client_secret)
end

function ImgurClient:get_client_id()
	return self.client_id
end

function ImgurClient:get_credits()
	return self.make_request('GET', 'credits', None, True)
end

function ImgurClient:get_auth_url(response_type)
	response_type = response_type or 'pin'
	return '%soauth2/authorize?client_id=%s&response_type=%s' % {API_URL, self.client_id, response_type}
end

function ImgurClient:authorize(response, grant_type)
	assert(response ~= nil, "Response was nil, cannot authorize it.")
	grant_type = grant_type or 'pin'
	
	local body = {
		client_id = self.client_id,
		client_secret = self.client_secret,
		grant_type = grant_type
	}
	
	if grant_type == 'authorization_code' then
		body.code = response
	else
		assert(false, "Debug, grant type wasn't authorization_code.")
	end
	
	return self.make_request('POST', 'oauth2/token', body, true)
end

function ImgurClient:prepare_headers(force_anon)
	force_anon = force_anon or false
	if force_anon or self.auth == nil then
		if self.client_id == nil then
			assert(false, "ImgurClientError: Client credentials not found!")
			--raise ImgurClientError('Client credentials not found!')
		else
			return {Authorization = 'Client-ID %s' % {self.get_client_id()}}
		end
	else
		return {Authorization = 'Bearer %s' % {self.auth.get_current_access_token()}}
	end
end

function ImgurClient:make_request(method, route, data, force_anon)
	assert(method ~= nil, "Method cannot be nil.")
	assert(route ~= nil, "Route cannot be nil.")
	data = data or nil
	force_anon = force_anon or false
	
	method = method.lower()
	if requests['method'] ~= nil then
		method_to_call = requests['method']
	else
		assert(false, "Requests did not contain a property named 'method'.")
	end

	header = self.prepare_headers(force_anon)
	local routedata = {route}
	local url = API_URL
	if string.find(route, 'oauth2') then
		url = url + ('3/%s' % routedata)
	end

	if lume.find({'delete', 'get'}, method) then
		response = method_to_call(url, header, data, data)
		-- response = method_to_call(url, headers=header, params=data, data=data)
	else
		response = method_to_call(url, header, data)
		-- the same, except without data
	end

	if response.status_code == 403 and self.auth ~= nil then
		self.auth.refresh()
		header = self.prepare_headers()
		if lume.find({'delete', 'get'}, method) then
			response = method_to_call(url, header, data, data)
		else
			response = method_to_call(url, header, data)
		end
	end

	self.credits = {
		UserLimit = response.headers.get('X-RateLimit-UserLimit'),
		UserRemaining = response.headers.get('X-RateLimit-UserRemaining'),
		UserReset = response.headers.get('X-RateLimit-UserReset'),
		ClientLimit = response.headers.get('X-RateLimit-ClientLimit'),
		ClientRemaining = response.headers.get('X-RateLimit-ClientRemaining')
	}

	-- Rate-limit check
	if response.status_code == 429 then
		assert(false, "ImgurClientRateLimitError: No more posts allowed.")
	end

	response_data = response.json()
	if response_data == nil then
		assert(false, "JSON decoding of response failed.")
	end

	if lume.find(response_data, 'data') and 
		isinstance(response_data['data'], dict) and
		lume.find(response_data['data'], 'error')
		then
		assert(false, "ImgurClientError: "..response_data['data']['error'] .. "\t" .. response.status_code)
	end

	if lume.find(response_data, 'data') then
		return response_data['data']
	else
		return response_data
	end
end

function ImgurClient:validate_user_context(username)
	assert(username == 'me' and self.auth == nil, "ImgurClientError: 'me' can only be used in the authenticated context.")
end

function ImgurClient:logged_in()
	assert(self.auth ~= nil, "ImgurClientError: Must be logged in to complete request.")
end

-- Account-related endpoints
function ImgurClient:get_account(username)
	self.validate_user_context(username)
	account_data = self.make_request('GET', 'account/%s' % {username})

	return Account(
		account_data['id'],
		account_data['url'],
		account_data['bio'],
		account_data['reputation'],
		account_data['created'],
		account_data['pro_expiration']
	)
end

function ImgurClient:get_gallery_favorites(username)
	self.validate_user_context(username)
	gallery_favorites = self.make_request('GET', 'account/%s/gallery_favorites' % {username})

	return build_gallery_images_and_albums(gallery_favorites)
end

function ImgurClient:get_account_favorites(username)
	self.validate_user_context(username)
	favorites = self.make_request('GET', 'account/%s/favorites' % {username})

	return build_gallery_images_and_albums(favorites)
end

function ImgurClient:get_account_submissions(username, page)
	page = page or 0
	self.validate_user_context(username)
	submissions = self.make_request('GET', 'account/%s/submissions/%d' % {username, page})

	return build_gallery_images_and_albums(submissions)
end

function ImgurClient:get_account_settings(username)
	self.logged_in()
	settings = self.make_request('GET', 'account/%s/settings' % {username})

	return AccountSettings(
		settings['email'],
		settings['high_quality'],
		settings['public_images'],
		settings['album_privacy'],
		settings['pro_expiration'],
		settings['accepted_gallery_terms'],
		settings['active_emails'],
		settings['messaging_enabled'],
		settings['blocked_users']
	)
end

--[[ 2 complex 3 me
function ImgurClient:change_account_settings(username, fields)
	post_data = {setting: fields[setting] for setting in set(self.allowed_account_fields).intersection(fields.keys())}
	return self.make_request('POST', 'account/%s/settings' % username, post_data)
end
]]
function ImgurClient:get_email_verification_status(username)
	self.logged_in()
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/verifyemail' % {username})
end

function ImgurClient:send_verification_email(username)
	self.logged_in()
	self.validate_user_context(username)
	return self.make_request('POST', 'account/%s/verifyemail' % {username})
end

--[[ 2 complex 4 me
function ImgurClient:get_account_albums(username, page=0)
	self.validate_user_context(username)

	albums = self.make_request('GET', 'account/%s/albums/%d' % {username, page})
	return [Album(album) for album in albums]
end
]]

function ImgurClient:get_account_album_ids(username, page)
	page = page or 0
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/albums/ids/%d' % {username, page})
end

function ImgurClient:get_account_album_count(username)
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/albums/count' % {username})
end

--[[ 2 complex 4 me
function ImgurClient:get_account_comments(username, sort, page)
	sort = sort or 'newest'
	page = page or 0
	self.validate_user_context(username)
	comments = self.make_request('GET', 'account/%s/comments/%s/%s' % {username, sort, page})

	return [Comment(comment) for comment in comments]
end
]]

function ImgurClient:get_account_comment_ids(username, sort, page)
	sort = sort or 'newest'
	page = page or 0
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/comments/ids/%s/%s' % {username, sort, page})
end

function ImgurClient:get_account_comment_count(username)
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/comments/count' % {username})
end

--[[ 2 complex 4 me
function ImgurClient:get_account_images(username, page)
	page = page or 0
	self.validate_user_context(username)
	images = self.make_request('GET', 'account/%s/images/%d' % {username, page})

	return [Image(image) for image in images]
end
]]

function ImgurClient:get_account_image_ids(username, page)
	page = page or 0
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/images/ids/%d' % {username, page})
end

function ImgurClient:get_account_images_count(username)
	self.validate_user_context(username)
	return self.make_request('GET', 'account/%s/images/count' % {username})
end

-- Album-related endpoints
function ImgurClient:get_album(album_id)
	album = self.make_request('GET', 'album/%s' % {album_id})
	return Album(album)
end

--[[ 2 complex 4 me
function ImgurClient:get_album_images(album_id)
	images = self.make_request('GET', 'album/%s/images' % {album_id})
	return [Image(image) for image in images]
end
]]

--[[ 2 complex 4 me
function ImgurClient:create_album(fields)
	post_data = {field: fields[field] for field in set(self.allowed_album_fields).intersection(fields.keys())}

	if 'ids' in post_data:
	self.logged_in()

	return self.make_request('POST', 'album', data=post_data)
end
]]

--[[ 2 complex 4 me
function ImgurClient:update_album(album_id, fields)
	post_data = {field: fields[field] for field in set(self.allowed_album_fields).intersection(fields.keys())}

	if isinstance(post_data['ids'], list):
	post_data['ids'] = ','.join(post_data['ids'])

	return self.make_request('POST', 'album/%s' % album_id, data=post_data)
end
]]

function ImgurClient:album_delete(album_id)
	return self.make_request('DELETE', 'album/%s' % album_id)
end
function ImgurClient:album_favorite(album_id)
	self.logged_in()
	return self.make_request('POST', 'album/%s/favorite' % album_id)
end
function ImgurClient:album_set_images(album_id, ids)
	if isinstance(ids, list) then
		ids = table.concat(ids, ",")
	end

	return self.make_request('POST', 'album/%s/' % {album_id}, {ids = ids})
end
function ImgurClient:album_add_images(album_id, ids)
	if isinstance(ids, list) then
		ids = table.concat(ids, ",")
	end

	return self.make_request('POST', 'album/%s/add' % {album_id}, {ids = ids})
end
function ImgurClient:album_remove_images(album_id, ids)
	if isinstance(ids, list) then
		ids = table.concat(ids, ",")
	end

	return self.make_request('DELETE', 'album/%s/remove_images' % {album_id}, {ids = ids})
end

-- Comment-related endpoints
function ImgurClient:get_comment(comment_id)
	comment = self.make_request('GET', 'comment/%d' % {comment_id})
	return Comment(comment)
end

function ImgurClient:delete_comment(comment_id)
	self.logged_in()
	return self.make_request('DELETE', 'comment/%d' % {comment_id})
end

function ImgurClient:get_comment_replies(comment_id)
	replies = self.make_request('GET', 'comment/%d/replies' % {comment_id})
	return format_comment_tree(replies)
end

function ImgurClient:post_comment_reply(comment_id, image_id, comment)
	self.logged_in()
	data = {
		image_id = image_id,
		comment = comment
	}

	return self.make_request('POST', 'comment/%d' % {comment_id}, data)
end

function ImgurClient:comment_vote(comment_id, vote)
	vote = vote or 'up'
	self.logged_in()
	return self.make_request('POST', 'comment/%d/vote/%s' % {comment_id, vote})
end

function ImgurClient:comment_report(comment_id)
	self.logged_in()
	return self.make_request('POST', 'comment/%d/report' % {comment_id})
end

-- Custom Gallery Endpoints
function ImgurClient:get_custom_gallery(gallery_id, sort, window, page)
	sort = sort or 'viral'
	window = window or 'week'
	page = page or 0
	
	gallery = self.make_request('GET', 'g/%s/%s/%s/%s' % {gallery_id, sort, window, page})
	return CustomGallery(
		gallery['id'],
		gallery['name'],
		gallery['datetime'],
		gallery['account_url'],
		gallery['link'],
		gallery['tags'],
		gallery['item_count'],
		gallery['items']
	)
end
--[[ 2 complex 4 me
function ImgurClient:get_user_galleries()
	self.logged_in()
	galleries = self.make_request('GET', 'g')

	return [CustomGallery(
		gallery['id'],
		gallery['name'],
		gallery['datetime'],
		gallery['account_url'],
		gallery['link'],
		gallery['tags']
		) for gallery in galleries]
end
]]
function ImgurClient:create_custom_gallery(name, tags)
	tags = tags or nil
	self.logged_in()
	data = {name = name}

	if tags then
		data['tags'] = table.concat(tags, ',')
	end

	gallery = self.make_request('POST', 'g', data)

	return CustomGallery(
		gallery['id'],
		gallery['name'],
		gallery['datetime'],
		gallery['account_url'],
		gallery['link'],
		gallery['tags']
	)
end

function ImgurClient:custom_gallery_update(gallery_id, name)
	self.logged_in()
	data = {
		id = gallery_id,
		name = name
	}

	gallery = self.make_request('POST', 'g/%s' % {gallery_id}, data)

	return CustomGallery(
		gallery['id'],
		gallery['name'],
		gallery['datetime'],
		gallery['account_url'],
		gallery['link'],
		gallery['tags']
	)
end

function ImgurClient:custom_gallery_add_tags(gallery_id, tags)
	self.logged_in()

	if tags then
		data = {tags = table.concat(tags, ',')}
	else
		assert(false, "ImgurClientError: tags must not be empty!")
	end

	return self.make_request('PUT', 'g/%s/add_tags' % {gallery_id}, data)
end

function ImgurClient:custom_gallery_remove_tags(gallery_id, tags)
	self.logged_in()

	if tags then
		data = {tags = table.concat(tags, ',')}
	else
		assert(false, "ImgurClientError: tags must not be empty!")
	end

	return self.make_request('DELETE', 'g/%s/remove_tags' % {gallery_id}, data)
end

function ImgurClient:custom_gallery_delete(gallery_id)
	self.logged_in()
	return self.make_request('DELETE', 'g/%s' % {gallery_id})
end

function ImgurClient:filtered_out_tags()
	self.logged_in()
	return self.make_request('GET', 'g/filtered_out')
end

function ImgurClient:block_tag(tag)
	self.logged_in()
	return self.make_request('POST', 'g/block_tag', {tag = tag})
end

function ImgurClient:unblock_tag(tag)
	self.logged_in()
	return self.make_request('POST', 'g/unblock_tag', {tag = tag})
end

-- Gallery-related endpoints
function ImgurClient:gallery(section, sort, page, window, show_viral)
	section = section or 'hot'
	sort = sort or 'viral'
	page = 0
	window = 'day'
	show_viral = show_viral or true
	if section == 'top' then
		response = self.make_request('GET', 'gallery/%s/%s/%s/%d?showViral=%s'
			% {section, sort, window, page, string.lower(show_viral)})
	else
		response = self.make_request('GET', 'gallery/%s/%s/%d?showViral=%s'
			% {section, sort, page, string.lower(show_viral)})
	end

	return build_gallery_images_and_albums(response)
end

function ImgurClient:memes_subgallery(sort, page, window)
	sort = sort or 'viral'
	page = page or 0
	window = window or 'week'
	
	if sort == 'top' then
		response = self.make_request('GET', 'g/memes/%s/%s/%d' % {sort, window, page})
	else
		response = self.make_request('GET', 'g/memes/%s/%d' % {sort, page})
	end

	return build_gallery_images_and_albums(response)
end

function ImgurClient:memes_subgallery_image(item_id)
	item = self.make_request('GET', 'g/memes/%s' % {item_id})
	return build_gallery_images_and_albums(item)
end

function ImgurClient:subreddit_gallery(subreddit, sort, window, page)
	sort = sort or 'time'
	window = window or 'week'
	page = page or 0
	
	if sort == 'top' then
		response = self.make_request('GET', 'gallery/r/%s/%s/%s/%d' % {subreddit, sort, window, page})
	else
		response = self.make_request('GET', 'gallery/r/%s/%s/%d' % {subreddit, sort, page})
	end

	return build_gallery_images_and_albums(response)
end

function ImgurClient:subreddit_image(subreddit, image_id)
	item = self.make_request('GET', 'gallery/r/%s/%s' % {subreddit, image_id})
	return build_gallery_images_and_albums(item)
end

function ImgurClient:gallery_tag(tag, sort, page, window)
	sort = sort or 'viral'
	page = page or 0
	window = window or 'week'
	
	if sort == 'top' then
		response = self.make_request('GET', 'gallery/t/%s/%s/%s/%d' % {tag, sort, window, page})
	else
		response = self.make_request('GET', 'gallery/t/%s/%s/%d' % {tag, sort, page})
	end

	return Tag(
		response['name'],
		response['followers'],
		response['total_items'],
		response['following'],
		response['items']
	)
end

function ImgurClient:gallery_tag_image(tag, item_id)
	item = self.make_request('GET', 'gallery/t/%s/%s' % {tag, item_id})
	return build_gallery_images_and_albums(item)
end

--[[ 2 complex 4 me
function ImgurClient:gallery_item_tags(item_id)
	response = self.make_request('GET', 'gallery/%s/tags' % {item_id})

	return [TagVote(
		item['ups'],
		item['downs'],
		item['name'],
		item['author']
		) for item in response['tags']]
--end
--]]


function ImgurClient:gallery_tag_vote(item_id, tag, vote)
	self.logged_in()
	response = self.make_request('POST', 'gallery/%s/vote/tag/%s/%s' % {item_id, tag, vote})
	return response
end

--[[ 2 complex 4 me
function ImgurClient:gallery_search(q, advanced=None, sort='time', window='all', page=0)
	if advanced:
	data = {field: advanced[field]
		for field in set(self.allowed_advanced_search_fields).intersection(advanced.keys())}
else:
	data = {'q': q}

	response = self.make_request('GET', 'gallery/search/%s/%s/%s' % (sort, window, page), data)
	return build_gallery_images_and_albums(response)
end
]]

function ImgurClient:gallery_random(page)
	page = page or 0
	response = self.make_request('GET', 'gallery/random/random/%d' % {page})
	return build_gallery_images_and_albums(response)
end

function ImgurClient:share_on_imgur(item_id, title, terms)
	terms = terms or 0
	self.logged_in()
	data = {
		title = title,
		terms = terms
	}

	return self.make_request('POST', 'gallery/%s' % {item_id}, data)
end

function ImgurClient:remove_from_gallery(item_id)
	self.logged_in()
	return self.make_request('DELETE', 'gallery/%s' % {item_id})
end

function ImgurClient:gallery_item(item_id)
	response = self.make_request('GET', 'gallery/%s' % {item_id})
	return build_gallery_images_and_albums(response)
end

function ImgurClient:report_gallery_item(item_id)
	self.logged_in()
	return self.make_request('POST', 'gallery/%s/report' % {item_id})
end

function ImgurClient:gallery_item_vote(item_id, vote)
	vote = vote or 'up'
	self.logged_in()
	return self.make_request('POST', 'gallery/%s/vote/%s' % {item_id, vote})
end

function ImgurClient:gallery_item_comments(item_id, sort)
	sort = sort or 'best'
	response = self.make_request('GET', 'gallery/%s/comments/%s' % {item_id, sort})
	return format_comment_tree(response)
end

function ImgurClient:gallery_comment(item_id, comment)
	self.logged_in()
	return self.make_request('POST', 'gallery/%s/comment' % {item_id}, {comment = comment})
end

function ImgurClient:gallery_comment_ids(item_id)
	return self.make_request('GET', 'gallery/%s/comments/ids' % {item_id})
end

function ImgurClient:gallery_comment_count(item_id)
	return self.make_request('GET', 'gallery/%s/comments/count' % {item_id})
end

-- Image-related endpoints
function ImgurClient:get_image(image_id)
	image = self.make_request('GET', 'image/%s' % {image_id})
	return Image(image)
end

function ImgurClient:upload_from_path(path, config, anon)
	config = config or nil
	anon = anon or true
	
	if not config then
		config = dict()
	end

	fd = io.open(path, 'rb')
	contents = fd:read("*all")
	b64 = base64.b64encode(contents)
	fd:close()

	data = {
		image = b64,
		type = 'base64',
	}
	
	--[[ 2 complex 4 me
	data.update({meta: config[meta] for meta in set(self.allowed_image_fields).intersection(config.keys())})
	]]
	return self.make_request('POST', 'upload', data, anon)
end

function ImgurClient:upload_from_url(url, config, anon)
	config = config or nil
	anon = anon or true
	if not config then
		config = dict()
	end

	data = {
		image = url,
		type = 'url',
	}

	--[[ 2 complex 4 me
	data.update({meta: config[meta] for meta in set(self.allowed_image_fields).intersection(config.keys())})
	]]
	return self.make_request('POST', 'upload', data, anon)
end

function ImgurClient:delete_image(image_id)
	return self.make_request('DELETE', 'image/%s' % {image_id})
end

function ImgurClient:favorite_image(image_id)
	self.logged_in()
	return self.make_request('POST', 'image/%s/favorite' % {image_id})
end

-- Conversation-related endpoints
--[[ 2 complex 4 me
function ImgurClient:conversation_list()
	self.logged_in()

	conversations = self.make_request('GET', 'conversations')
	return [Conversation(
		conversation['id'],
		conversation['last_message_preview'],
		conversation['datetime'],
		conversation['with_account_id'],
		conversation['with_account'],
		conversation['message_count'],
		) for conversation in conversations]
end
]]

function ImgurClient:get_conversation(conversation_id, page, offset)
	page = page or 1
	offset = offset or 0
	self.logged_in()

	conversation = self.make_request('GET', 'conversations/%d/%d/%d' % {conversation_id, page, offset})
	return Conversation(
		conversation['id'],
		conversation['last_message_preview'],
		conversation['datetime'],
		conversation['with_account_id'],
		conversation['with_account'],
		conversation['message_count'],
		conversation['messages'],
		conversation['done'],
		conversation['page']
	)
end

function ImgurClient:create_message(recipient, body)
	self.logged_in()
	return self.make_request('POST', 'conversations/%s' % {recipient}, {body = body})
end

function ImgurClient:delete_conversation(conversation_id)
	self.logged_in()
	return self.make_request('DELETE', 'conversations/%d' % {conversation_id})
end

function ImgurClient:report_sender(username)
	self.logged_in()
	return self.make_request('POST', 'conversations/report/%s' % {username})
end

function ImgurClient:block_sender(username)
	self.logged_in()
	return self.make_request('POST', 'conversations/block/%s' % {username})
end

-- Notification-related endpoints
function ImgurClient:get_notifications(new)
	new = new or true
	self.logged_in()
	response = self.make_request('GET', 'notification', {new = string.lower(new)})
	return build_notifications(response)
end

function ImgurClient:get_notification(notification_id)
	self.logged_in()
	response = self.make_request('GET', 'notification/%d' % {notification_id})
	return build_notification(response)
end

function ImgurClient:mark_notifications_as_read(notification_ids)
	self.logged_in()
	return self.make_request('POST', 'notification', table.concat(notification_ids, ','))
end

-- Memegen-related endpoints
--[[ 2 complex 4 me
function ImgurClient:default_memes()
	response = self.make_request('GET', 'memegen/defaults')
	return [Image(meme) for meme in response]
end
]]