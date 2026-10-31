/// Runs the cassette lookups against a fake yt-dlp script
/datum/unit_test/cassette_media
	var/stub_file = "data/ytdl_test_stub.sh"
	var/runs_file = "data/ytdl_test_runs.txt"
	var/pwned_file = "data/ytdl_test_pwned"
	var/old_ytdl
	var/finished = 0
	var/list/results = list()

/datum/unit_test/cassette_media/Destroy()
	CONFIG_SET(string/invoke_youtubedl, old_ytdl)
	for(var/file in list(stub_file, runs_file, pwned_file))
		fdel(file)
	GLOB.ytdl_cache.Cut()
	GLOB.ytdl_cooldowns.Cut()
	return ..()

/// Makes the fake yt-dlp print this, it counts how many times it was started
/datum/unit_test/cassette_media/proc/write_stub(body)
	fdel(stub_file)
	text2file("#!/bin/sh\necho run >> [runs_file]\n[body]\n", stub_file)

/datum/unit_test/cassette_media/proc/song_json(url = "https://media.example.com/a.mp3", live = FALSE)
	return "echo '{\"url\":\"[url]\",\"title\":\"Test <b>Song</b>\",\"webpage_url\":\"https://youtu.be/abc\",\"duration\":12.6,\"uploader\":\"Someone\",\"is_live\":[live ? "true" : "false"]}'"

/datum/unit_test/cassette_media/proc/count_runs()
	if(!fexists(runs_file))
		return 0
	return length(splittext(trim(file2text(runs_file)), "\n"))

/datum/unit_test/cassette_media/proc/slow_lookup(url)
	results[url] = ytdl_lookup(url)
	finished++

/datum/unit_test/cassette_media/Run()
	if(world.system_type != UNIX)
		return
	old_ytdl = CONFIG_GET(string/invoke_youtubedl)
	CONFIG_SET(string/invoke_youtubedl, "sh [stub_file]")

	var/url = "https://youtu.be/abc"
	write_stub(song_json())
	var/list/info = ytdl_lookup(url)
	TEST_ASSERT_NOTNULL(info, "yt-dlp found nothing for a normal song")
	TEST_ASSERT_EQUAL(info["status"], FLOXY_STATUS_COMPLETED, "The lookup doesn't look like a finished Floxy download")
	TEST_ASSERT_EQUAL(info["endpoints"][1], "https://media.example.com/a.mp3", "The wrong link is played")
	var/list/metadata = info["metadata"]
	TEST_ASSERT_EQUAL(metadata["title"], "Test Song", "The title wasn't stripped of html")
	TEST_ASSERT_EQUAL(metadata["duration"], 13, "The duration wasn't rounded up to whole seconds")
	TEST_ASSERT_EQUAL(metadata["artist"], "Someone", "The uploader isn't used as the artist")
	TEST_ASSERT_EQUAL(metadata["url"], url, "The song doesn't point back at its page")
	TEST_ASSERT_EQUAL(count_runs(), 1, "yt-dlp wasn't started exactly once")

	TEST_ASSERT_NOTNULL(ytdl_lookup(url), "A song that was just looked up isn't found again")
	TEST_ASSERT_EQUAL(count_runs(), 1, "A song that was just looked up started yt-dlp again")
	if(!cassette_uses_floxy())
		TEST_ASSERT_EQUAL(get_cassette_media(url), info, "Cassettes don't use yt-dlp when Floxy isn't set up")
		TEST_ASSERT_EQUAL(fetch_cassette_metadata(url), metadata, "Cassette metadata doesn't use yt-dlp when Floxy isn't set up")

	TEST_ASSERT_NOTNULL(ytdl_lookup("https://files.catbox.moe/stock.m4a"), "The stock cassette host isn't allowed")
	TEST_ASSERT_EQUAL(count_runs(), 2, "yt-dlp wasn't started for the stock cassette host")
	TEST_ASSERT_NOTNULL(ytdl_lookup("https://www.youtube.com/watch?v=abc"), "A normal youtube link isn't allowed")
	TEST_ASSERT_NOTNULL(ytdl_lookup("https://music.youtube.com/watch?v=abc"), "A youtube music link isn't allowed")
	TEST_ASSERT_EQUAL(count_runs(), 4, "yt-dlp wasn't started for the youtube links")
	for(var/bad_url in list("https://evil.example.com/a.mp3", "https://youtu.be.evil.example.com/abc", "https://evil.example.com/?x=https://youtu.be/abc", "https://user@youtu.be/abc", "file:///etc/passwd"))
		TEST_ASSERT_NULL(ytdl_lookup(bad_url), "[bad_url] was looked up")
	TEST_ASSERT_EQUAL(count_runs(), 4, "yt-dlp was started for a site that isn't allowed")

	// hyphens and underscores must reach yt-dlp untouched
	TEST_ASSERT_NOTNULL(ytdl_lookup("https://soundcloud.com/some-artist/some_track-1"), "A link with - or _ in it wasn't looked up")
	TEST_ASSERT(ytdl_url_shell_safe("https://soundcloud.com/some-artist/some_track-1"), "A normal link was called unsafe")
	TEST_ASSERT(!ytdl_url_shell_safe("https://youtu.be/abc'x"), "A link with a quote was called safe")

	// whatever is in the link can't get to the shell
	ytdl_lookup("https://youtu.be/abc';touch [pwned_file];'")
	ytdl_lookup("https://youtu.be/$(touch [pwned_file])")
	TEST_ASSERT(!fexists(pwned_file), "A link ran a command on the server")

	write_stub("exit 1")
	TEST_ASSERT_NULL(ytdl_lookup("https://youtu.be/fails"), "A failing yt-dlp still gave a song")
	write_stub("echo this is not json")
	TEST_ASSERT_NULL(ytdl_lookup("https://youtu.be/garbage"), "Output that isn't json still gave a song")
	write_stub(song_json("file:///etc/passwd"))
	TEST_ASSERT_NULL(ytdl_lookup("https://youtu.be/local"), "A link that isn't http(s) was handed out")
	write_stub("echo '{\"url\":\"https://media.example.com/a.m3u8\",\"protocol\":\"m3u8_native\",\"title\":\"x\"}'")
	TEST_ASSERT_NOTNULL(ytdl_lookup("https://youtu.be/hls"), "A hls playlist was refused, soundcloud only has those")
	write_stub("echo '{\"url\":\"https://media.example.com/manifest.mpd\",\"protocol\":\"http_dash_segments\",\"title\":\"x\"}'")
	TEST_ASSERT_NULL(ytdl_lookup("https://youtu.be/dash"), "A dash stream was handed out, clients can't play it")
	write_stub(song_json(live = TRUE))
	TEST_ASSERT_NULL(ytdl_lookup("https://youtu.be/live"), "A live stream was put on a tape")

	// the server keeps running while yt-dlp works, and only so many run at once
	write_stub("sleep 1\n[song_json()]")
	for(var/i in 1 to YTDL_MAX_RUNNING + 1)
		INVOKE_ASYNC(src, PROC_REF(slow_lookup), "https://youtu.be/slow[i]")
	TEST_ASSERT_EQUAL(GLOB.ytdl_running, YTDL_MAX_RUNNING, "The server waited for yt-dlp, or too many ran at once")
	UNTIL_OR_TIMEOUT(finished == YTDL_MAX_RUNNING + 1, 20 SECONDS)
	TEST_ASSERT_EQUAL(finished, YTDL_MAX_RUNNING + 1, "Lookups waiting for a free slot never finished")
	for(var/slow_url in results)
		TEST_ASSERT_NOTNULL(results[slow_url], "[slow_url] wasn't found")
	TEST_ASSERT_EQUAL(GLOB.ytdl_running, 0, "A finished lookup didn't free its slot")

	TEST_ASSERT(!ytdl_user_cooldown("cassettetest"), "A player's first lookup was made to wait")
	TEST_ASSERT(ytdl_user_cooldown("cassettetest"), "A player could start lookups back to back")
	GLOB.ytdl_cooldowns["cassettetest"] = world.time - 1
	TEST_ASSERT(!ytdl_user_cooldown("cassettetest"), "A player still had to wait after the cooldown ended")
