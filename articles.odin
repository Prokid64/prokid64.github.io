package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

ARTICLE_INDEX :: sandwich {
`<h1>Table of Contents</h1>
<ul id="articles">`,
`</ul>`
}

generateArticles:: proc(entries: [dynamic]blogEntry) -> string
{
	builder:= strings.builder_make();

	for entry, index in entries
	{
		strings.write_string(&builder, "<li>\n");

		strings.write_string(&builder, "<a href=\"");
		strings.write_string(&builder, entry.url);
		strings.write_string(&builder, "\">\n");
		strings.write_string(&builder, entry.title);
		strings.write_string(&builder, "</a>\n");

		strings.write_string(&builder, "<p>");
		fmt.sbprintfln(&builder, "%d.%d.%d", entry.date.day, entry.date.month, entry.date.year);
		strings.write_string(&builder, "</p>");

		strings.write_string(&builder, "</li>\n");
	}

	data:= fillSandwich(ARTICLE_INDEX, strings.to_string(builder));
	return data;
}
