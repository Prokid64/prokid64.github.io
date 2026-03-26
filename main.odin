package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

import cm "vendor:commonmark"

sandwich :: struct
{
	top, bottom: string
}

HEAD :: sandwich {
`<!DOCTYPE html>
<html>
<head>
<title>Andrew Barcelo</title>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="/style.css">
</head>
<body>`,

`<p id="copyright"> © 2026 Andrew Barcelo</p>
</body></html>`
}

HEADER ::
`<div id="header">
<h1>Andrew <span class="highlight">Barcelo</span></h1>
<p id="subtitle">In Pursuit of Better Software</p>
<ul>
<li>
	<a href="/index.html">
	Home
	</a>
</li>
<li>
	<a href="/about.html">
	About
	</a>
</li>
<li>
	<a href="/articles.html">
	Articles
	</a>
</li>
</ul>
</div>`

ARTICLE_BODY :: sandwich {
`<div id="article_body">`,
`</div>`
}

ABOUT ::
`<h2>In Pursuit of Better Software</h2>
<p>
In our current materialist society, we neglect what the real problems are in the computers industry.
</p>
<p>
Everyone wants the newest hardware. We are taught that good hardware means better performance. Yet we have in fact missed the problem entirely.
Our hardware is perfectly capable of doing almost anything we need or want it to do. The real bottleneck in this era isn't hardware, it's software.
</p>
<p>
If we want to bring back fully-functional, performant computer applications, then we need to reform our mindset and methods in programming.
</p>
<p id="bio"><em>
One of my main passions in life is to make high-performance software. This website is a repository of everything I do and learn on this journey.
Professionally, I am pursuing a career in embedded software/firmware.
I also love video games and their design. Naturally, programming games is one of my favorite hobbies.
</em></p>`

ABOUT_SHORT ::
`<p id="bio"><em>
One of my main passions in life is to make high-performance software. This website is a repository of everything I do and learn on this journey.
Professionally, I am pursuing a career in embedded software/firmware.
I also love video games and their design. Naturally, programming games is one of my favorite hobbies.
</em></p>`

// Parsing - Simple interface
main :: proc() {
	fmt.printf("CMark version: %v\n", cm.version_string())

	dir, err := os.open("./blog");
	if err != nil
	{
		fmt.eprintfln("Error loading directory: %v", err);
		return;
	}
	defer os.close(dir);

	files, err2 := os.read_dir(dir, 0);
	if err2 != nil
	{
		fmt.eprintfln("Error loading directory files: %v", err);
		return;
	}

	entries: [dynamic]blogEntry;

	for file in files
	{
		if file.name[len(file.name)-2:] == "md"
		{
			fmt.printfln("Generating html for file: %s", file.name);

			strippedFileName:= strings.clone(file.name[:len(file.name)-2]);
			htmlFileName:= strings.concatenate({ strippedFileName, "html" });

			data, entryData := preproccessMarkdownFile(file.fullpath);
			defer delete(data);
			entryData.url = strings.concatenate({ "blog/", htmlFileName });
			if entryData.title == "" do continue;
			append(&entries, entryData);
			parseMarkdownFile(data, strings.concatenate({ "./blog/", htmlFileName }))
		}
		else do continue;
	}

	articles:= generateArticles(entries);
	generateHomepage(articles);
	generateAbout();
	generateArticlesPage(articles);
}

fillSandwich :: proc(s: sandwich, filling: string) -> string
{
	return strings.concatenate({ s.top, filling, s.bottom });
}

generateHomepage :: proc(indexData: string)
{
	data:= strings.concatenate({ HEADER, ABOUT_SHORT, indexData });
	newData:= fillSandwich(HEAD, data);

	raw := transmute([]u8)newData;
	ok := os.write_entire_file("./index.html", raw);
}

generateAbout :: proc()
{
	data:= strings.concatenate({ HEADER, ABOUT });
	defer delete(data);
	newData:= fillSandwich(HEAD, data);

	raw := transmute([]u8)newData;
	ok := os.write_entire_file("./about.html", raw);
}

generateArticlesPage :: proc(indexData: string)
{
	data:= strings.concatenate({ HEADER, indexData });
	defer delete(data);
	newData := fillSandwich(HEAD, data);

	raw := transmute([]u8)newData;
	ok := os.write_entire_file("./articles.html", raw);
}

parseMarkdownFile :: proc(data: []byte, dest: string)
{
	root := cm.parse_document(&data[0], len(data), cm.DEFAULT_OPTIONS)
	defer cm.node_free(root)

	html := cm.render_html(root, cm.DEFAULT_OPTIONS)
	defer cm.free(html)

	htmlStr:= fillSandwich(ARTICLE_BODY, string(html))
	htmlStr = strings.concatenate({ HEADER, htmlStr });
	htmlStr = fillSandwich(HEAD, htmlStr);

	raw := transmute([]u8)htmlStr;

	ok := os.write_entire_file(dest, raw);
}
