// Cassette music comes from Floxy when it is set up. Without it songs are looked up by running yt-dlp (INVOKE_YOUTUBEDL)
// on the server, players stream the result from the source and nothing is saved on disk.

/// url -> list("info", "expires")
GLOBAL_LIST_EMPTY(ytdl_cache)
/// ckey -> world.time they can start another lookup
GLOBAL_LIST_EMPTY(ytdl_cooldowns)
GLOBAL_VAR_INIT(ytdl_running, 0)

/// Cassettes use Floxy when it's fully set up
/proc/cassette_uses_floxy()
	return !!(CONFIG_GET(string/floxy_url) && CONFIG_GET(string/floxy_username) && CONFIG_GET(string/floxy_password))

/// Metadata for a song, list("title", "url", "duration", "artist", "album")
/proc/fetch_cassette_metadata(url, mob/requester)
	if(cassette_uses_floxy())
		return SSfloxy.fetch_media_metadata(url)
	var/list/info = ytdl_lookup(url, requester)
	return info?["metadata"]

/// Gets a song ready to be played ahead of time
/proc/queue_cassette_media(url)
	if(cassette_uses_floxy())
		SSfloxy.queue_media(url)
	else
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(ytdl_lookup), url)

/// Waits for a song and returns list("status", "url", "endpoints", "metadata"), null if it couldn't be found
/proc/get_cassette_media(url, mob/requester)
	if(cassette_uses_floxy())
		return SSfloxy.download_and_wait(url, timeout = 30 SECONDS, discard_failed = TRUE)
	return ytdl_lookup(url, requester)

/// Looks the URL up with yt-dlp and returns what Floxy would
/proc/ytdl_lookup(url, mob/requester)
	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl || !is_http_protocol(url) || !ytdl_url_allowed(url))
		return null
	var/list/cached = GLOB.ytdl_cache[url]
	if(cached && cached["expires"] > world.time)
		return cached["info"]
	if(requester?.ckey && ytdl_user_cooldown(requester.ckey))
		to_chat(requester, span_warning("The loader is still busy with your last request, give it a few seconds."))
		return null
	UNTIL_OR_TIMEOUT(GLOB.ytdl_running < YTDL_MAX_RUNNING, YTDL_TIMEOUT SECONDS)
	if(GLOB.ytdl_running >= YTDL_MAX_RUNNING)
		return null
	GLOB.ytdl_running++
	var/list/output = ytdl_run(ytdl, url)
	GLOB.ytdl_running--
	if(output[SHELLEO_ERRORLEVEL])
		log_music("yt-dlp failed for [url]: [output[SHELLEO_STDERR]]")
		return null
	var/list/info = ytdl_parse(url, output[SHELLEO_STDOUT])
	if(!info)
		log_music("yt-dlp gave nothing usable for [url]")
		return null
	for(var/old_url in GLOB.ytdl_cache.Copy())
		if(GLOB.ytdl_cache[old_url]["expires"] <= world.time)
			GLOB.ytdl_cache -= old_url
	GLOB.ytdl_cache[url] = list("info" = info, "expires" = world.time + YTDL_CACHE_TIME)
	return info

/// Returns TRUE if this player has to wait, otherwise starts their cooldown
/proc/ytdl_user_cooldown(ckey)
	if(GLOB.ytdl_cooldowns[ckey] > world.time)
		return TRUE
	GLOB.ytdl_cooldowns[ckey] = world.time + YTDL_USER_COOLDOWN
	return FALSE

/// Only sites from REQUEST_INTERNET_ALLOWED are looked up, players can put any link on a tape and yt-dlp would fetch all of them
/proc/ytdl_url_allowed(url)
	var/allowed = CONFIG_GET(string/request_internet_allowed) || YTDL_DEFAULT_ALLOWED
	var/regex/allowed_regex = regex("^https?://(\[\\w-]+\\.)*([replacetext("[allowed],[YTDL_ALWAYS_ALLOWED]", ",", "|")])", "i")
	return !!allowed_regex.Find(url)

/// Returns list(errorcode, stdout, stderr). shell() waits for the command, which freezes the whole server while yt-dlp works,
/// so on unix it is started in the background and the result is polled
/proc/ytdl_run(ytdl, url)
	var/scrubbed = shell_url_scrub(url)
	var/static/run_id = 0
	if(world.system_type != UNIX)
		return world.shelleo("[ytdl] --geo-bypass --format \"[YTDL_FORMAT]\" --dump-single-json --no-playlist --extractor-args \"youtube:lang=en\" -- \"[scrubbed]\"")
	run_id++
	var/base = "data/ytdl_[run_id]"
	var/done_file = "[base].done"
	shell("( timeout [YTDL_TIMEOUT] [ytdl] --geo-bypass --format '[YTDL_FORMAT]' --dump-single-json --no-playlist --extractor-args 'youtube:lang=en' -- '[scrubbed]' > [base].out 2> [base].err && echo 0 > [done_file] || echo 1 > [done_file] ) < /dev/null > /dev/null 2>&1 &")
	UNTIL_OR_TIMEOUT(fexists(done_file), (YTDL_TIMEOUT + 5) SECONDS)
	var/errorcode = 1
	var/stdout = ""
	var/stderr = "timed out"
	if(fexists(done_file))
		errorcode = text2num(trim(file2text(done_file)))
		stderr = ""
	if(fexists("[base].out"))
		stdout = file2text("[base].out")
	if(fexists("[base].err"))
		stderr = file2text("[base].err") || stderr
	for(var/leftover in list(done_file, "[base].out", "[base].err"))
		fdel(leftover)
	return list(errorcode, stdout, stderr)

/// Turns yt-dlp's json into the list Floxy gives out, null if the song can't be played
/proc/ytdl_parse(url, json)
	if(!length(json))
		return null
	var/list/data
	try
		data = json_decode(json)
	catch
		return null
	if(!islist(data) || data["is_live"])
		return null
	var/direct_url = data["url"]
	if(!istext(direct_url) || !is_http_protocol(direct_url))
		return null
	var/page_url = data["webpage_url"]
	if(!istext(page_url) || !is_http_protocol(page_url))
		page_url = url
	var/duration = isnum(data["duration"]) ? ceil(data["duration"]) : 0
	return list(
		"status" = FLOXY_STATUS_COMPLETED,
		"url" = page_url,
		"endpoints" = list(direct_url),
		"metadata" = list(
			"title" = ytdl_text(data["title"]) || url,
			"url" = page_url,
			"duration" = duration,
			"artist" = ytdl_text(data["artist"]) || ytdl_text(data["uploader"]),
			"album" = ytdl_text(data["album"]),
		),
	)

/// Text from the internet that is shown to players
/proc/ytdl_text(text)
	if(!istext(text))
		return null
	return trim(STRIP_HTML_FULL(text, 100)) || null
