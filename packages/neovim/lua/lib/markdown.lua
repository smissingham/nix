function BlockQuote(block)
	local first = block.content[1]
	if not first or first.t ~= "Para" then
		return nil
	end

	local marker = first.content[1]
	if not marker or marker.t ~= "Str" then
		return nil
	end

	local kind = marker.text:match("^%[!([^%]]+)%]$")
	if not kind then
		return nil
	end

	table.remove(first.content, 1)

	if first.content[1] and first.content[1].t == "Space" then
		table.remove(first.content, 1)
	end

	local title = pandoc.Strong({ pandoc.Str(kind:gsub("^%l", string.upper)) })
	if #first.content > 0 then
		table.insert(first.content, 1, pandoc.Space())
	end

	table.insert(first.content, 1, title)

	local result = {
		pandoc.RawBlock("typst", "#block(fill: luma(245), inset: 8pt, radius: 4pt)["),
	}

	for _, item in ipairs(block.content) do
		table.insert(result, item)
	end

	table.insert(result, pandoc.RawBlock("typst", "]"))

	return result
end
