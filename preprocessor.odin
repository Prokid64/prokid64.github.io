package main

import "core:fmt"
import "core:os"
import "core:strings"
import "core:strconv"

date :: struct {
	day, month, year: int
}

blogEntry :: struct
{
	url: string,
	title: string,
	date: date
}

preprocessorMode :: enum u8 {
	COPYING,
	SCANNING,
	TITLE,
	DATE
}

preproccessMarkdownFile :: proc(path: string) -> (out: []byte, entryData: blogEntry)
{
	data, fileok := os.read_entire_file(path);
	// defer delete(data);
	if !fileok
	{
		fmt.eprintfln("Error loading file");
		return;
	}

	builder:= strings.builder_make();

	mode:= preprocessorMode.COPYING;
	it := string(data)

	for line in strings.split_lines_iterator(&it) {
		trimmed := strings.trim_space(line)

		if trimmed == "{START_CONFIG}"
		{ mode = .SCANNING; continue; }
		else if trimmed == "{END_CONFIG}"
		{ mode = .COPYING; continue; }

		switch mode {
		case .SCANNING:
			switch trimmed {
	   			case "TITLE":
				{ mode = .TITLE; continue }
	      		case "DATE":
				{ mode = .DATE; continue }
      		}
		case .COPYING:
			strings.write_string(&builder, strings.concatenate({line, "\n"}))
		case .TITLE:
			entryData.title = line;
			fmt.printfln("Title: %s", entryData.title);
			mode = .SCANNING;
			continue;
		case .DATE:
			entryData.date = processDateFromString(line);
			fmt.printfln("Date: %d.%d.%d", entryData.date.day, entryData.date.month, entryData.date.year)

			mode = .SCANNING;
			continue;
		}
	}

	parsed := strings.to_string(builder);
	data = transmute([]byte)parsed;

	return data, entryData;
}

processDateFromString :: proc(s: string) -> (result: date)
{
	values:= strings.split(s, ".");
	defer delete(values);

	ok: bool;

	result.day, ok = strconv.parse_int(values[0]);
	if !ok do fmt.print("ERROR PARSING DATE");

	result.month, ok = strconv.parse_int(values[1]);
	if !ok do fmt.print("ERROR PARSING DATE");

	result.year, ok = strconv.parse_int(values[2]);
	if !ok do fmt.print("ERROR PARSING DATE");

	return;
}
