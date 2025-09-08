return {
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			local cond = require("nvim-autopairs.conds")
			local ts_conds = require("nvim-autopairs.ts-conds")

			npairs.setup({
				check_ts = true,
				ts_config = {
					lua = { "string", "comment" },
					javascript = { "string", "template_string" },
					typescript = { "string", "template_string" },
					nix = { "string", "comment" },
				},
				enable_check_bracket_line = true,
				ignored_next_char = [=[[%w%%%'%[%"%.%`%$]]=],
			})

			-- Add custom rules to prevent pairing when matching close exists
			local Rule = require("nvim-autopairs.rule")

			-- Override default rules with smarter conditions
			npairs.clear_rules()
			npairs.add_rules({
				Rule("(", ")")
					:with_pair(cond.not_after_regex("[%)%]%}]"))
					:with_pair(ts_conds.is_not_ts_node({ "string", "comment" })),
				Rule("[", "]")
					:with_pair(cond.not_after_regex("[%)%]%}]"))
					:with_pair(ts_conds.is_not_ts_node({ "string", "comment" })),
				Rule("{", "}")
					:with_pair(cond.not_after_regex("[%)%]%}]"))
					:with_pair(ts_conds.is_not_ts_node({ "string", "comment" })),
				Rule("'", "'", { "lua", "vim" })
					:with_pair(cond.not_after_regex("%w"))
					:with_pair(ts_conds.is_ts_node({ "string", "comment" })),
				Rule('"', '"'):with_pair(cond.not_after_regex("%w")):with_pair(ts_conds.is_not_ts_node({ "comment" })),
				Rule("`", "`"):with_pair(cond.not_after_regex("%w")):with_pair(ts_conds.is_not_ts_node({ "comment" })),
				-- Nix-specific rule: add semicolon after closing brace in certain contexts
				Rule("{", "};", "nix"):with_pair(function(opts)
					-- Check if we're in a context that needs semicolon (attribute sets, let expressions)
					local line = opts.line
					return line:match("^%s*[%w_%-%.]*%s*=%s*$") -- assignment context
						or line:match("let%s+") -- let expression
						or line:match("inherit%s+") -- inherit statement
				end):with_pair(ts_conds.is_not_ts_node({ "string", "comment" })),
			})
		end,
	},
}
